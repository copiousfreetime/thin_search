module ThinSearch
  class QueryResult

    attr_reader :documents
    attr_reader :query

    def initialize(query, documents)
      @query = query
      @documents = documents
    end

    def size
      @documents.size
    end
    alias count size
  end
end
