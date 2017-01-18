module LogSanity
  class RequestLogger

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      ll = logger.level
      if silence = silence_path?(request)
        logger.level = Logger::ERROR
      end

      start(request: request)
      resp = @app.call(env)
      resp[2] = Rack::BodyProxy.new(resp[2]) do
        finish(env: env, request: request, response: resp, silence: silence)
      end
      resp
    rescue Exception => e
      finish(env: env, request: request, exception: e, silence: silence)
      raise e
    ensure
      logger.level = ll
      ActiveSupport::LogSubscriber.flush_all!
    end


    private

    def start(params)
      LogSanity.reset_fields
      instrumenter = ActiveSupport::Notifications.instrumenter
      instrumenter.start 'request.action_dispatch', params
    end

    def finish(params)
      instrumenter = ActiveSupport::Notifications.instrumenter
      instrumenter.finish 'request.action_dispatch', params
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
