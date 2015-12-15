require 'amalgalite'
require 'thin_search/store'
require 'thin_search/conversion'

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

    # Public: Search for and yield the resulting items
    #
    # yields each object if a block is given
    #
    # Returns an Array of result instances if no block is given
    def search(query, &block)
      if block_given? then
        store.search_index(name, query).each do |document|
          yield Conversion.from_indexable_document(document)
        end
        nil
      else
        store.search_index(name, query).map do |document|
          Conversion.from_indexable_document(document)
        end
      end
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
