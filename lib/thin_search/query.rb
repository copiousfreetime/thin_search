require 'map'

module ThinSearch
  # Public: Represents all the information in making a query to the index
  #
  # It can chain on itself so you can call method after method on it to do
  # things
  #
  class Query

    LIMIT = 1_000

    attr_reader :contexts
    attr_reader :page
    attr_reader :per_page # also :size
    attr_reader :expression
    attr_reader :index
    attr_reader :facets

    def initialize(index, expression, opts = {})
      @index      = index
      @expression = expression.to_s

      @result     = nil
      @page       = nil
      @per_page   = nil

      options     = Map.options(opts)
      @context    = options.getopt(:contexts)
      @facets     = options.getopt(:facets, :default => Hash.new)
      paginate(options)
    end

    def faceted?
      facets.size > 0
    end

    def paginated?
      !per_page.nil?
    end

    def paginate(opts)
      options = Map.options(opts)
      self.page = options.getopt(:page)
      self.per = options.getopt(:per_page) || options.getopt(:size)
      self
    end

    def page=(p)
      @page = more_than_zero(p) || 1
      self
    end

    def per=(p)
      @per_page = more_than_zero(p) || LIMIT
      self
    end

    def result
      @result ||= index.execute_query(self)
    end

    def limit
      per_page
    end

    def offset
      (page - 1)*per_page
    end

    private

    def more_than_zero(i)
      return nil if i.nil?
      return nil if i <= 0
      i
    end
  end
end
