module LogSanity
  module Extensions
    module BroadcastLogger
      extend ActiveSupport::Concern

      def initialize_copy(other)
        super
        @broadcasts = other.broadcasts.deep_dup
      end

    end
  end
end
