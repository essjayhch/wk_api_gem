require 'httparty'
require 'logger'
require 'thread'

module LL
  module WK
    module API
      module Connection
        class HTTParty
          include ::HTTParty

          SUPPORTS_CURSOR = false

          def self.authenticate_payload(email, password)
            {
              user: {
                email: email,
                password: password
              }
            }.to_json
          end

          def self.authenticate(email, password)
            resp = post('/session/new',
                        body: authenticate_payload(email, password),
                        headers: { 'Content-Type' => 'application/json' })
            yield(resp) if block_given?
            resp
          end

          def auth
            "Token token=\"#{@token}\", email=\"#{@email}\""
          end

          def initialize(url:, email:, password:)
            self.class.base_uri url
            @email = email
            @password = password
          end

          def authenticate!(force = false)
            return self unless token_expired? or force

            retries = 0
            begin
              self.class.authenticate(email, password) do |resp|
                self.class.trap_resp_code(resp.code, AuthenticationError)
                @token = resp.parsed_response['token']
                @token_issued = Time.now
              end
            rescue AuthenticationError => e
              retries += 1
              sleep retries
              retry if retries < 2
              raise e
            end
            self
          end

          def self.sanitize_endpoint(endpoint)
            File.join('', endpoint)
          end

          def response_from_api(endpoint, params)
            retries = 0
            resp = self.class.get(self.class.sanitize_endpoint(endpoint), query: params, headers: { 'Authorization' => auth })
            self.class.trap_resp_code(resp.code)
            yield(resp) if block_given?
            resp
          rescue Error => e
            authenticate!(true)
            retries += 1
            sleep 1
            retry if retries < 3
            raise e
          end

          def page_count(resp)
            resp['paging']&.[]('total')
          end

          def from_api(endpoint, params, &block)
            retries = 0
            return with_cursor(endpoint, params, &block) if SUPPORTS_CURSOR
            with_page(endpoint, params, &block)
          rescue AuthenticationError => e
            authenticate!
            retries += 1
            retry if retries < 3
            raise e
          end

          def with_page(endpoint, params)
            params[:page] ||= 1
            pages_remain = params[:page] + 1
            array = []
            while params[:page] < pages_remain
              response_from_api(endpoint, params) do |resp|
                resp['data'].each do |item|
                  array << item
                  yield(item) if block_given?
                end
                pages_remain = page_count(resp)
                params[:page] += 1
              end
            end
            array
          end

          def with_cursor(endpoint, params)
            params[:cursor] ||= 0
            array = []
            while !params[:cursor].nil?
              response_from_api(endpoint, params) do |resp|
                resp['data'].each do |item|
                  array << item
                  yield(item) if block_given?
                end
                params[:cursor] = resp[:cursor]
              end
            end
            array
          end

          def self.trap_resp_code(code, klass = Error)
            case code
            when 403
              raise AuthenticationError, 'Unauthorized'
            when 404
              raise klass, 'Invalid endpoint'
            when 400..499
              raise klass, 'Client error #{code}'
            when 500..599
              raise klass, "Server Error #{code}"
            else
              puts code
            end
          end

          def token_expired?
            return true unless token
            true unless (Time.now - token_issued.to_i).to_i < 76400
          end

          attr_reader :token, :token_issued, :email, :password

          class Error < StandardError
          end

          class AuthenticationError < Error
          end
        end
      end
    end
  end
end
