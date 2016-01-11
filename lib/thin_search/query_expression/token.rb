require 'digest'

module ThinSearch
  class QueryExpression
    SINGLE_QUOTE = "'".freeze
    DOUBLE_QUOTE = '"'.freeze

    class Token
      attr_accessor :quote_mark
      attr_accessor :value

      def self.quote_mark(s)
        if s.start_with?(SINGLE_QUOTE) && s.end_with?(SINGLE_QUOTE) then
          SINGLE_QUOTE
        elsif s.start_with?(DOUBLE_QUOTE) && s.end_with?(DOUBLE_QUOTE) then
          DOUBLE_QUOTE
        else
          nil
        end
      end

      def self.quoted?(s)
        !!quote_mark(s)
      end

      def self.unquote(s)
        quoted?(s) ? s[1..-2] : s
      end


      def initialize(token)
        @value      = token
        @quote_mark = Token.quote_mark(token)
        unquote! if quoted?
      end

      def ==(other)
        quote_mark == other.quote_mark && value == other.value
      end

      def quoted?
        !!@quote_mark
      end

      def unquote!
        @value.replace(Token.unquote(value))
      end

      def to_s
        value
      end

      def sql_escape(char)
        value.gsub(char, "#{char}#{char}")
      end

      def md5
        ::Digest::MD5.hexdigest(value)
      end

      def double_quoted
        "#{DOUBLE_QUOTE}#{sql_escape(DOUBLE_QUOTE)}#{DOUBLE_QUOTE}"
      end

      def single_quoted
        "#{SINGLE_QUOTE}#{sql_escape(SINGLE_QUOTE)}#{SINGLE_QUOTE}"
      end

      def inspect(*args, &block)
        if quoted? then
          "#{ value} q=#{ quote_mark }"
        else
          super
        end
      end
    end
  end
end
