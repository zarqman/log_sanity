module LogSanity
  module LogSubscriber
    class ActionMailer < Base

      def deliver(event)
        info do
          { 'at' => Time.now,
            'event' => 'mail_send',
            'from' => Array(event.payload[:from]),
            'to' => Array(event.payload[:to])
          }
        end
      end

      def receive(event)
        info do
          { 'at' => Time.now,
            'event' => 'mail_receive',
            'from' => Array(event.payload[:from]),
            'to' => Array(event.payload[:to])
          }
        end
      end

    end
  end
end
