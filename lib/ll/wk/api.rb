require 'll/wk/api/connection'
module LL
  module WK
    # API Functionality for clients of the WebKiosk
    module API
      module_function
      def self.connect(url:, email:, password:)
        API::Connection.factory(url: url, email: email, password: password)
      end
    end
  end
end
