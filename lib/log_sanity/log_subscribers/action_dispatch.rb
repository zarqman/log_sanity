module LogSanity
  module LogSubscriber
    class ActionDispatch < Base

      def request(event)
        payload = event.payload
        return if payload[:silence]

        info do
          request = payload[:request]
          response = payload[:response]
          method = payload[:method] || (request.request_method rescue nil) || 'UNKNOWN'
          f2 = {
            'at' => event_start(event),
            'event' => "#{request.scheme}_#{method.downcase}",
            'ip' => request.remote_ip,
            'rq' => request.uuid,
            # 'path' => request.path,           # path only
            # 'path' => request.filtered_path,  # path + params
            # 'params' => request.filtered_parameters,
          }

          unless fields['route']
            unless fields['path']
              # most errors repopulate path, so look for the original one first.
              # original_path is, however, unfiltered.
              f2['path']   = request.filtered_env['action_dispatch.original_path']
              f2['path'] ||= request.path
            end
            unless fields['params']
              fp = request.filtered_parameters rescue {parse_error: "#{$!.class}: #{$!.message.truncate(100)}"}
              f2['params'] = fp if fp.present?
            end
          end

          fields['duration'] ||= {}
          fields['duration']['total'] = event.duration.round
            # rewrites 'total', which includes more of time spent in middleware
          fields['status'] ||= response[0].to_i if response
          compute_tags(request)
          f2.merge fields
        end
      end

      def redirect(event)
        log 'redirect', event.payload[:location]
      end


      private

      def compute_tags(request)
        Rails.application.config.log_tags.each_with_index do |tag, idx|
          res = case tag
          when Proc
            tag.call(request)
          when Symbol
            request.send(tag)
          else
            tag
          end
          if res.is_a?(Hash)
            fields.deep_merge!(res)
          elsif tag.is_a? Symbol
            log tag.to_s, res
          else
            log "tag#{idx}", res
          end
        end
      end

    end
  end
end
