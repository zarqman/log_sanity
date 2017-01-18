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
          e['params'] = job.arguments if job.arguments.any?
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
          e['params'] = job.arguments if job.arguments.any?
          e
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
      #     e['params'] = job.arguments if job.arguments.any?
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
          e['params'] = job.arguments if job.arguments.any?
          e
        end
      end

    end
  end
end
