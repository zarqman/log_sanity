module LogSanity
  module Extensions
    module ActiveSupportSubscriber
      extend ActiveSupport::Concern

      module ClassMethods
        def detach_from(namespace, notifier=ActiveSupport::Notifications)
          subscribers.select{|s| s.is_a? self}.each do |subscriber|
            subscriber.public_methods(false).each do |event|
              pattern = "#{event}.#{namespace}"
              notifier.notifier.listeners_for(pattern).each do |listener|
                if listener.instance_variable_get(:@delegate) == subscriber
                  notifier.unsubscribe listener
                  subscriber.patterns.delete pattern
                end
              end
            end
            subscribers.delete subscriber if subscriber.patterns.empty?
          end
        end
      end

    end
  end
end
