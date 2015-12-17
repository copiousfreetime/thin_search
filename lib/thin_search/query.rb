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
    attr_reader :per_page
    attr_reader :expression
    attr_reader :facets
    attr_reader :default_index

    # Constructor:
    # expression - the search expression designation what text to find
    # options    - additional search parameters
    #              :page - which page of the full results to return
    #              :per_page - how many results per_page
    #              :contexts - limit to these contexts (classes)
    #              :facets   - filter by facet items
    #              :index - set the Index instance that this query is run
    #                       against by default
    #
    def initialize(expression, opts = {})
      @expression    = expression.to_s

      @result        = nil
      @page          = nil
      @per_page      = nil

      options        = Map.options(opts)
      @context       = options.getopt(:contexts)
      @facets        = options.getopt(:facets, :default => Hash.new)
      @default_index = options.getopt(:index)

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

    # Public: Execute the query on the given index
    #
    # Returns a QueryResult
    #
    def result(index = default_index)
      index.execute_query(self)
    end
    alias execute result

    def limit
      per_page
    end

    def offset
      (page - 1)*per_page
    end

    private

    def more_than_zero(i)
      return nil if i.nil?
      i = Integer(i)
      return nil if i <= 0
      i
    end
  end
end
