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
    include ActiveSupport::TaggedLogging::Formatter
      # tags are ignored when rendering as json
      # however, tags are prepended when rendering with string_formatter

    def call(severity, timestamp, progname, msg)
      if msg.is_a? Hash
        msg.reverse_merge!('at' => timestamp) unless msg.key?('at')
      elsif msg.is_a? String
        if string_formatter
          msg = "#{tags_text}#{msg}" if current_tags.any?
          return string_formatter.call(severity, timestamp, progname, msg)
        else
          msg = {'at' => timestamp, 'message' => msg}
        end
      else
        msg = {'at' => timestamp, 'object' => msg.inspect}
      end
      msg['at'] = msg['at'].utc
      "#{msg.to_json}\n"
    end

    attr_writer :string_formatter

    def string_formatter
      return @string_formatter if defined?(@string_formatter)
      @string_formatter ||= ActiveSupport::Logger::SimpleFormatter.new
    end

  end
end
