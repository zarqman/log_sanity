module LogSanity
  module LogSubscriber
    class ActiveJob < Base

      def enqueue(event)
        info do
          job = event.payload[:job]
          e = {
            'at' => Time.now,
            'event' => 'job_enqueue',
            'job' => job.class.name,
            'id' => job.job_id,
            'queue' => job.queue_name
          }
          e['params'] = format_args(job.arguments) if job.arguments.any?
          if error = event.payload[:exception_object] || job.enqueue_error
            e['error'] = error
          elsif event.payload[:aborted]
            e['callback_halt'] = 'before_enqueue'
          end
          e
        end
      end

      def enqueue_at(event)
        info do
          job = event.payload[:job]
          e = {
            'at' => Time.now,
            'event' => 'job_enqueue',
            'job' => job.class.name,
            'id' => job.job_id,
            'queue' => job.queue_name,
            'start_at' => job.scheduled_at
          }
          e['params'] = format_args(job.arguments) if job.arguments.any?
          if error = event.payload[:exception_object] || job.enqueue_error
            e['error'] = error
          elsif event.payload[:aborted]
            e['callback_halt'] = 'before_enqueue'
          end
          e
        end
      end

      def enqueue_all(event)
        info do
          total = event.payload[:jobs].size
          enqueued = event.payload[:enqueued_count]
          { 'at' => Time.now,
            'event' => 'bulk_enqueue',
            'enqueued' => enqueued,
            'failed' => total - enqueued,
          }
        end
      end

      # def perform_start(event)
      #   info do
      #     job = event.payload[:job]
      #     e = {
      #       'at' => Time.now,
      #       'event' => 'job_start',
      #       'job' => job.class.name,
      #       'id' => job.job_id,
      #       'queue' => job.queue_name,
      #     }
      #     e['params'] = format_args(job.arguments) if job.arguments.any?
      #     e
      #   end
      # end

      def perform(event)
        info do
          job = event.payload[:job]
          e = {
            'at' => Time.now,
            'event' => 'job_perform',
            'job' => job.class.name,
            'id' => job.job_id,
            'queue' => job.queue_name,
            'duration' => {'total' => event.duration.round}
          }
          e['params'] = format_args(job.arguments) if job.arguments.any?
          if error = event.payload[:exception_object]
            e['error'] = error
          elsif event.payload[:aborted]
            e['callback_halt'] = 'before_perform'
          end
          e
        end
      end


      private

      def format_args(arg)
        case arg
        when Hash
          arg.transform_values{|val| format_args val }
        when Array
          arg.map{|val| format_args val }
        when GlobalID::Identification
          arg.to_global_id rescue "#{arg.class}(#{arg.try(:id)})"
        else
          arg
        end
      end

    end
  end
end
