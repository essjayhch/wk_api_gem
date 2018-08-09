require "llwk_api/version"
require 'curb'
require 'json'
module LlwkApi
  class Connect
    attr_accessor :token, :endpoint, :params,
                  :config, :email, :token_issued

    def auth
      "Token token=\"#{@token}\", email=\"#{@email}\""
    end

    def curl_easy(uri)
      Curl::Easy.new(uri) do |c|
        c.follow_location = true
        c.headers['Authorization'] = auth unless token_expired?
        yield(c) if block_given?
      end
    end

    def initialize(url, email, password)
      @api_url = url
      @email = email
      @password = password
      generate_token
    end

    def token_payload
      { user: { email: @email, password: @password } }.to_json
    end

    def token_expired?
      return true unless token
      token_age = (Time.now - token_issued.to_i).to_i
      true unless token_age < 76400
    end

    def generate_token
      Curl::Easy.new("#{@api_url}/session/new") do |curl|
        curl.headers['Content-Type'] = 'application/json'
        curl.http_post(token_payload)
        resp = JSON.parse(curl.body_str)
        raise 'Invalid' if resp['status'] && resp['status'] == 'unauthenticated'
        @token_issued = Time.now
        @token = resp['token']
      end
    end

    def search_for_users(from_date = 0, to_date = Time.now.to_i)
      from_api('users?', "date_from=#{from_date}&date_to=#{to_date}")
    end

    def search_for_user_album_items(userid)
      from_api('user_album_items?', "user_id=#{userid}")
    end

    def with_each_page_data(resp)
      resp['data'].each { |d| yield d }
      rescue NoMethodError => e
      raise e
    end

    def page_count(resp)
      resp['paging']&.[]('total')
    end

    def from_api(end_point, params)
      # gather data from the api
      array = []
      curl_easy("#{@api_url}/#{end_point}#{params}") do |curl|
        with_get(curl) do |out|
          with_each_page_data(out) do |result|
            array << result
          end
          array << do_pagination(end_point, params, page_count(out)) unless page_count(out).zero?
        end
      end
      array.flatten!
      array
      rescue StandardError => e
        raise e
    end

    def with_get(http)
      http.perform
      out = JSON.parse(http.body_str)
      yield(out)
      out
    end

    def do_pagination(end_point, params, pages)
      # grabs data from each of the pages returned by the API
      results = []
      (2..pages).each do |page|
        curl_easy("#{@api_url}/#{end_point}#{params}&page=#{page}") do |curl|
          with_get(curl) { |resp| with_each_page_data(resp) { |result| results << result } }
        end
      end
      results
    end

  end
end
