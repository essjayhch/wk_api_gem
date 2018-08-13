require 'll/wk/api/connection/httparty'
require 'll/wk/api/connection/curb'
module LL
  module WK
    module API
      module Connection
        module_function

        def factory(url:, email:, password:, type: Connection::HTTParty)
          type.new(url: url, email: email, password: password)
        end
      end
    end
  end
end
