module LogSanity
  class Railtie < Rails::Railtie
    config.logsanity               = ActiveSupport::OrderedOptions.new
    config.logsanity.enabled       = false
    config.logsanity.json_strings  = false
    config.logsanity.silence_paths = []

    initializer "log_sanity.extensions" do
      ActiveSupport.on_load(:action_controller) do
        # runs for each of AC::Base, AC::API
        include LogSanity::Extensions::ActionControllerHelper
      end
    end

    initializer "log_sanity.configure", before: :load_config_initializers do |app|
      ActiveSupport::BroadcastLogger.include LogSanity::Extensions::BroadcastLogger
      app.config.log_tags ||= []

      if app.config.logsanity.enabled
        orig_formatter = Rails.logger.formatter
        Rails.logger.formatter = LogSanity::Formatter.new
        if app.config.logsanity.json_strings
          Rails.logger.formatter.string_formatter = false
        elsif orig_formatter
          Rails.logger.formatter.string_formatter = orig_formatter
        end

        app.middleware.swap Rails::Rack::Logger, LogSanity::RequestLogger

        show_exceptions_app = app.config.exceptions_app || ActionDispatch::PublicExceptions.new(Rails.public_path)
        app.middleware.use LogSanity::RoutingErrorCatcher, show_exceptions_app


        ActiveSupport.on_load(:action_cable_connection) do
          prepend LogSanity::Extensions::ActionCableConnection
        end
        ActiveSupport.on_load(:action_cable) do
          # set just ActionCable's logger to :warn to silence several non-instrumented logs
          orig_logger = logger || Rails.logger
          if orig_logger.level < Logger::WARN
            self.logger = orig_logger.clone.tap do |l|
              l.level = Logger::WARN
            end
          end

          LogSanity::LogSubscriber::ActionCable.attach_to :action_cable
        end

        ActiveSupport.on_load(:action_controller, run_once: true) do
          ActionController::LogSubscriber.detach_from :action_controller
          LogSanity::LogSubscriber::ActionController.attach_to :action_controller
        end

        ActiveSupport.on_load(:action_dispatch_request) do
          ActionDispatch::LogSubscriber.detach_from :action_dispatch
          LogSanity::LogSubscriber::ActionDispatch.attach_to :action_dispatch
        end

        ActiveSupport.on_load(:action_mailer) do
          ActionMailer::LogSubscriber.detach_from :action_mailer
          LogSanity::LogSubscriber::ActionMailer.attach_to :action_mailer
        end

        ActiveSupport.on_load(:action_view) do
          ActionView::LogSubscriber.detach_from :action_view
          if ActionView::LogSubscriber.logger.debug?
            ActiveSupport::Notifications.unsubscribe 'render_template.action_view'
            ActiveSupport::Notifications.unsubscribe 'render_layout.action_view'
          end
        end

        ActiveSupport.on_load(:active_job) do
          ActiveJob::LogSubscriber.detach_from :active_job
          LogSanity::LogSubscriber::ActiveJob.attach_to :active_job
        end

        ActiveSupport.on_load(:active_record) do
          # ActiveRecord::LogSubscriber.detach_from :active_record
            # only logs at :debug level. since log_sanity offers no replacements, don't detach. if logging in
            # production at :debug, may silence anyway by adding an initializer with the above detach_from.
          if ActiveRecord::Base.logger.debug?
            Rails.logger.info '[LogSanity] ActiveRecord::Base.logger in debug mode and will still log queries'
          end
        end

      end
    end

  end
end
