# middleware to catch and sanely handle routing errors without treating them
# like all other exceptions (that is, without verbose backtraces and other
# such).
# intended to be added to the end of the middleware stack (nearest the app).
# while built on top of ShowExceptions to reuse its error rendering logic,
# does not replace it.

module LogSanity
  class RoutingErrorCatcher < ActionDispatch::ShowExceptions

    def call(env)
      request = ActionDispatch::Request.new env
      _, headers, body = response = @app.call(env)

      if headers['X-Cascade'] == 'pass'
        body.close if body.respond_to?(:close)
        raise ActionController::RoutingError, "No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}"
      end

      response
    rescue ActionController::RoutingError => exception
      if Rails.version >= '7.1'
        backtrace_cleaner = request.get_header('action_dispatch.backtrace_cleaner')
        wrapper = ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, exception)
        if wrapper.show?(request)
          render_exception(request, wrapper)
        else
          raise exception
        end
      else
        if request.show_exceptions?
          render_exception(request, exception)
        else
          raise exception
        end
      end
    end

  end
end
