require 'll/wk/api/connection'
module LL
  module WK
    # API Functionality for clients of the WebKiosk
    module API
      module_function
      def self.connect(url:, email:, password:)
        Connection.new(url, email, password)
      end
    end
  end
end
