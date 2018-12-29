# Receives a variety of objects for logging.
# LogSanity itself sends Hashes which are formatted with #to_json.
# Other than Strings, will embed any other object into a jsonified hash.
# Strings are a bit of a special case and by default continue to be formatted
# with whatever Rails' formatter originally was. As such, it can be configured
# using `config.log_formatter`. This keeps exception backtraces and other
# various logs still as Strings. If you prefer Strings to also be turned into
# jsonified messages, set `config.logsanity.json_strings = true`.

module LogSanity
  class Formatter < Logger::Formatter

    def call(severity, timestamp, progname, msg)
      if msg.is_a? Hash
        msg['at'] = timestamp unless msg.key?('at')
      elsif msg.is_a? String
        if string_formatter
          return string_formatter.call(severity, timestamp, progname, msg)
        else
          msg = {'at' => timestamp, 'message' => msg}
        end
      else
        msg = {'at' => timestamp, 'object' => msg.inspect}
      end
      if msg['at'].is_a? Float
        monot = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        msg['at'] = Time.now - (monot - msg['at'])
      end
      msg['at'] = msg['at'].utc
      "#{msg.to_json}\n"
    end

    # noop; for TaggedLogging compatibility
    def clear_tags! ; end
    def tagged(*_) ; yield self ; end
    def current_tags ; [] ; end

    attr_accessor :string_formatter

    def string_formatter
      @string_formatter ||= ActiveSupport::Logger::SimpleFormatter.new
    end

  end
end
