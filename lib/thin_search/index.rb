require 'amalgalite'
require 'thin_search/store'

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

    def count
      @store.document_count_for(name)
    end

    def add(indexable)
      Array(indexable).tap do |list|
        store.add_documents_to_index(name, list)
      end
    end

    def remove(indexable)
      Array(indexable).tap do |list|
        store.remove_documents_from_index(name, list)
      end
    end

    # Public: Find a particular document in the index
    #
    # Using the context and context_id, find the given document in the index and
    # return it.
    #
    # Returns a Document or nil if not found
    def find(indexable)
      store.find_one_document_in_index(name, indexable)
    end
  end
end
