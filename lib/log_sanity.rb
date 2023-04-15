%w( formatter
    railtie
    log_subscribers/base
    log_subscribers/action_cable
    log_subscribers/action_controller
    log_subscribers/action_dispatch
    log_subscribers/action_mailer
    log_subscribers/active_job
    middleware/request_logger
    middleware/routing_error_catcher
    extensions/action_cable_connection
    extensions/action_controller_helper
    extensions/active_support_subscriber
  ).each do |fn|
  require_relative "log_sanity/#{fn}"
end

if Rails.version < '6'
  ActiveSupport::Subscriber.include LogSanity::Extensions::ActiveSupportSubscriber
end

module LogSanity
  module_function

  def fields
    Thread.current[:logsanity_fields] || reset_fields
  end

  def reset_fields
    Thread.current[:logsanity_fields] = {}.with_indifferent_access
  end

  def log(key, val)
    fields[key.to_s] = val
  end
end
