module LogSanity
  module LogSubscriber
    class Base < ::ActiveSupport::LogSubscriber

      private
      delegate :fields, :log, to: LogSanity

    end
  end
end
