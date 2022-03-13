module LogSanity
  module LogSubscriber
    class ActionCable < Base

      def process(event)
        payload = event.payload
        log 'event', 'ws_connect'
        log 'status', payload[:status]
        # logged by the actiondispatch subscriber
      end

      def on_close(event)
        payload = event.payload
        request = payload[:request]
        info do
          e = {
            'at' => Time.now,
            'event' => 'ws_disconnect',
            'ip' => request.remote_ip,
            'rq' => request.uuid,
            'duration' => {'socket' => "#{payload[:connection_sec].round}s"}
          }
          e['reason'] = payload[:reason] if payload[:reason]
          e
        end
      end

    end
  end
end
