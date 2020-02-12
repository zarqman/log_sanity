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
            'at' => event.time,
            'event' => "#{request.scheme}_#{method.downcase}",
            'ip' => request.remote_ip,
            'rq' => request.uuid,
            # 'params' => request.filtered_params,
            # 'path' => request.filtered_path,
          }

          # unless fields['route']
          #   # most errors repopulate path, so look for the original one first.
          #   # original_path is, however, unfiltered.
          #   fields['path'] = payload[:env]['action_dispatch.original_path']
          #   fields['path'] ||= request.filtered_path
          # end

          fields['duration'] ||= {}
          fields['duration']['total'] = event.duration.round
            # rewrites 'total', which includes more of time spent in middleware
          fields['status'] ||= response[0].to_i if response
          compute_tags(request)
          f2.merge fields
        end
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
