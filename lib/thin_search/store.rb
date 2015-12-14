require 'amalgalite'
require 'pathname'
require 'thin_search/document'
require 'thin_search/store_operations'

module ThinSearch
  class Store
    attr_reader :db

    def initialize(path)
      @db               = ::Amalgalite::Database.new(path.to_s)
      @index_operations = Hash.new
    end

    def create_index(index_name)
      operations_for_index(index_name)[StoreOperations::CreateIndex].call(db)
    end

    def drop_index(index_name)
      operations_for_index(index_name)[StoreOperations::DropIndex].call(db)
    end

    def has_index?(name)
      db.schema.tables.has_key?(name)
    end

    def add_document_to_index(index_name, document)
      operations_for_index(index_name)[StoreOperations::Insert].call(db, document)
    end

    def add_documents_to_index(index_name, documents)
      operations_for_index(index_name)[StoreOperations::BulkInsert].call(db, documents)
    end

    def document_count_for(index_name)
      operations_for_index(index_name)[StoreOperations::DocumentCount].call(db)
    end

    def search_index(index_name, query, &block)
      search_op = operations_for_index(index_name)[StoreOperations::Search]
      search_op.call(db, query) do |document|
        yield document
      end
    end

    private

    def operations_for_index(index_name)
      @index_operations[index_name] || {
        StoreOperations::CreateIndex   => StoreOperations::CreateIndex.new(index_name),
        StoreOperations::DropIndex     => StoreOperations::DropIndex.new(index_name),
        StoreOperations::Insert        => StoreOperations::Insert.new(index_name),
        StoreOperations::BulkInsert    => StoreOperations::BulkInsert.new(index_name),
        StoreOperations::DocumentCount => StoreOperations::DocumentCount.new(index_name),
        StoreOperations::Search        => StoreOperations::Search.new(index_name),
      }
    end
  end
end

require 'thin_search/store_operations'
