module ThinSearch
  # Every search string that is passed to a store is parsed by QueryExpression
  # in order to properly generate the query to pass to the sqlite search index.
  class QueryExpression

    # The original string passed in
    attr_accessor :raw

    # Just token matches
    attr_accessor :tokens

    # Conditional expressions for specific fields. Currently we only support
    # explicit matching
    attr_accessor :expressions

    ATOMIZER_REGEX= %r`
      # Capture double quotes strings
      (?: " [^"]+ " ) |

      # Capture single quoted strings
      (?: ' [^']+ ' ) |

      # Capture anything that is not whitespace
      (?: [^\s]+ )
    `iomx


    OPS = %w[ : = ]
    OPS_REGEX= /([#{OPS.join('')}])/

    SubExpression = Struct.new( :lhs, :op, :rhs )
    class SubExpression
      def to_s
        "#{lhs}#{op}#{rhs}"
      end
    end

    def self.for(query)
      new(query)
    end

    def initialize(query)
      @raw         = query.to_s.dup
      @tokens      = []
      @expressions = []
      parse
    end

    private

    def parse
      atoms = raw.scan(ATOMIZER_REGEX)
      input = atoms.map{|atom| atom.split(OPS_REGEX)}.flatten.compact.delete_if{|atom| atom.empty?}

      #
      while token = input.shift do
        op, val = input.take(2)

        # if the current token is followed by a : or = and then there is another
        # token after that then we have a 'x = y' expression
        if OPS.include?(op) && val then
          expression = SubExpression.new(Token.new(token), op, Token.new(val))
          expressions.push(expression)
          input.shift(2)
        else
          tokens.push(Token.new(token))
        end
      end
    end
  end
end
require 'thin_search/query_expression/token'
