require 'amalgalite'
require 'thin_search/store'
require 'thin_search/conversion'
require 'thin_search/query'
require 'thin_search/query_result'

module ThinSearch
  class Index
    DEFAULT_NAME = "search"

    attr_reader :store
    attr_reader :name

    def initialize(opts = {:store => nil, :name => DEFAULT_NAME})
      @store = opts.fetch(:store)
      @name  = opts.fetch(:name)

      @store.create_index(@name) unless @store.has_index?(@name)
    end

    # Public: Return the number of documents in the index
    #
    # Returns integer
    def count
      @store.document_count_for(name)
    end

    # Public: Add one or more documents to the index
    #
    # indexable - an indexable document, or an array of indexable documents
    #
    # Returns nothing
    def add(indexable)
      documents = to_indexable_documents(indexable)
      store.add_documents_to_index(name, documents)
    end

    def remove(indexable)
      documents = to_indexable_documents(indexable)
      store.remove_documents_from_index(name, documents)
    end

    # Public: Find a particular document in the index
    #
    # Using the context and context_id, find the given document in the index and
    # return it.
    #
    # Returns a Document or nil if not found
    def find(indexable)
      document = Conversion.to_indexable_document(indexable)
      store.find_one_document_in_index(name, document)
    end

    # Public: Update a single document in the index
    #
    # This finds the given document with the same context/context_id in the
    # index and updates its indexable content with the new values from the input
    # document.
    #
    # Returns a Document or nil
    def update(indexable)
      document = Conversion.to_indexable_document(indexable)
      store.update_document_in_index(name, document)
    end

    # Public: Search for and return the Query
    #
    # expression - the search expression designation what text to find
    # options    - additional search parameters
    #              :page - which page of the full results to return
    #              :per_page - how many results per_page
    #              :contexts - limit to these contexts (classes)
    #
    # Returns the Query
    def search(expression, options = {})
      Query.new(expression, options.merge(:index => self))
    end

    # Public: Query the index for Results
    #
    # query - the Query object that is going to be run
    #
    # Returns Result
    #
    def execute_query(query)
      documents = store.search_index(name, query)
      QueryResult.new(query, documents)
    end

    # Public: Removes all documents from the index
    #
    # Returns nothing
    def truncate
      store.truncate_index(name)
    end

    private

    def to_indexable_documents(indexable)
      list = [indexable].flatten
      list.map { |item| Conversion.to_indexable_document(item) }
    end
  end
end
