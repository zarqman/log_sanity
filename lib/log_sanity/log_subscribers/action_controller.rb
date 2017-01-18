module LogSanity
  module LogSubscriber
    class ActionController < Base
      INTERNAL_PARAMS = %w(controller action format _method only_path)

      def process_action(event)
        payload = event.payload
        params  = payload[:params].except(*INTERNAL_PARAMS)
        format  = payload[:format]

        # log 'method', payload[:method]
        # log 'path', payload[:path]
        # log 'controller', payload[:controller]
        # log 'action', payload[:action]
        log 'route', "#{payload[:controller]}##{payload[:action]}"
        log 'format', format
        log 'params', params if params.present?

        status = payload[:status]
        if status.nil? && payload[:exception].present?
          exception_class_name = payload[:exception].first
          status = ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
        end

        durations = {'total' => event.duration.round}
        additions = ::ActionController::Base.log_process_action(payload)
        additions.each do |add|
          if add =~ /^([^:]+):?\s*([0-9.]+)(ms)?/
            ms = $2.to_f.round
            durations[$1.downcase] = ms if ms > 0
          end
        end

        log 'duration', durations
        log 'status', status
      end

      def halted_callback(event)
        log 'filter_chain_halt', event.payload[:filter].inspect
      end

      def send_file(event)
        log 'send_file', event.payload[:path]
      end

      def redirect_to(event)
        log 'redirect', event.payload[:location]
      end

      def send_data(event)
        log 'send_data', event.payload[:filename] || 'binary'
      end

    end
  end
end
