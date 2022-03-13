module LogSanity
  module LogSubscriber
    class Base < ::ActiveSupport::LogSubscriber

      private
      delegate :fields, :log, to: LogSanity

      def event_start(event)
        if event.time.is_a? Float
          # convert event's monotonic start .time to a Time
          Time.current - event.duration/1000.0
        else
          event.time
        end
      end

    end
  end
end
