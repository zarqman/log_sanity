module LogSanity
  class RequestLogger

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      conditionally_silence(request) do |silence|
        payload = {env: env, request: request, silence: silence}
        handle = start(payload)
        begin
          status, headers, body = response = @app.call(env)
          payload[:response] = response
          body = Rack::BodyProxy.new(body){ handle.finish }
          if response.frozen?
            [status, headers, body]
          else
            response[2] = body
            response
          end
        rescue Exception => e
          payload[:exception] = e
          handle.finish
          raise e
        end
      end
    ensure
      ActiveSupport::LogSubscriber.flush_all!
    end

    def conditionally_silence(request)
      if silence = silence_path?(request)
        logger.silence do
          yield silence
        end
      else
        yield silence
      end
    end



    private

    def start(payload)
      LogSanity.reset_fields
      instrumenter = ActiveSupport::Notifications.instrumenter
      instrumenter.build_handle('request.action_dispatch', payload).tap do |handle|
        handle.start
      end
    end

    def silence_path?(request)
      Rails.application.config.logsanity.silence_paths.any? do |s|
        case s
        when Regexp
          s =~ request.path
        when String
          s == request.path
        end
      end
    end

    def logger
      Rails.logger
    end

  end
end
