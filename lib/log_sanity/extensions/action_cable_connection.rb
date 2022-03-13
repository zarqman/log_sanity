module LogSanity
  module Extensions
    module ActionCableConnection
      extend ActiveSupport::Concern

      def close(reason: nil, **args)
        @close_reason = reason
        super
      end

      def process
        payload = { request: request }
        ActiveSupport::Notifications.instrument("process.action_cable", payload) do
          status, _, _ = response = super
          payload[:status] = status==-1 ? 101 : status
          response
        end
      end

      def reject_unauthorized_connection
        logger.instance_variable_get(:@logger).silence(Logger::FATAL) do
          super
        end
      end

      def on_close(reason, code)
        payload = {
          connection_sec: Time.now - @started_at,
          request: request
        }
        payload[:reason] = @close_reason if @close_reason
        ActiveSupport::Notifications.instrument("on_close.action_cable", payload) do
          super
        end
      end

    end
  end
end
