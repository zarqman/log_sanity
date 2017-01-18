module LogSanity
  module Extensions
    module ActionControllerHelper
      extend ActiveSupport::Concern

      def log_field(key, val)
        LogSanity.log key, val
      end

    end
  end
end
