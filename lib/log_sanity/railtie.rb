module LogSanity
  class Railtie < Rails::Railtie
    config.logsanity               = ActiveSupport::OrderedOptions.new
    config.logsanity.enabled       = false
    config.logsanity.json_strings  = false
    config.logsanity.silence_paths = []

    initializer "log_sanity.configure" do |app|
      app.config.log_tags ||= []
      if app.config.logsanity.enabled
        orig_formatter = Rails.logger.formatter
        Rails.logger.formatter = LogSanity::Formatter.new
        Rails.logger.formatter.string_formatter = orig_formatter unless app.config.logsanity.json_strings

        if defined?(ActionController)
          require 'action_controller/log_subscriber'
          ActionController::LogSubscriber.detach_from :action_controller
        end
        if defined?(ActionMailer)
          require 'action_mailer/log_subscriber'
          ActionMailer::LogSubscriber.detach_from :action_mailer
        end
        if defined?(ActionView)
          require 'action_view/log_subscriber'
          ActionView::LogSubscriber.detach_from :action_view
        end
        if defined?(ActiveJob)
          require 'active_job/logging'
          ActiveJob::Logging::LogSubscriber.detach_from :active_job
        end
        if defined?(ActiveRecord)
          require 'active_record/log_subscriber'
          ActiveRecord::LogSubscriber.detach_from :active_record
        end

        LogSanity::LogSubscriber::ActionController.attach_to :action_controller
        LogSanity::LogSubscriber::ActionDispatch.attach_to :action_dispatch
        LogSanity::LogSubscriber::ActionMailer.attach_to :action_mailer
        LogSanity::LogSubscriber::ActiveJob.attach_to :active_job

        app.middleware.swap Rails::Rack::Logger, LogSanity::RequestLogger

        show_exceptions_app = app.config.exceptions_app || ActionDispatch::PublicExceptions.new(Rails.public_path)
        app.middleware.use LogSanity::RoutingErrorCatcher, show_exceptions_app
      end
    end

  end
end
