require 'amalgalite'
require 'pathname'
require 'thin_search/document'
require 'thin_search/store_operations'

module ThinSearch
  class Store
    attr_reader :path

    def initialize(path)
      @path             = Pathname.new(path.to_s)
      @path.dirname.mkpath
      @index_operations = Hash.new
      @db = nil
    end

    def db
      if @db && @db.open? then
        @db
      else
        @db = ::Amalgalite::Database.new(path.to_s)
      end
    end

    def create_index(index_name)
      operations_for_index(index_name)[StoreOperations::CreateIndex].call(db)
    end

    def drop_index(index_name)
      operations_for_index(index_name)[StoreOperations::DropIndex].call(db)
    end

    def truncate_index(index_name)
      operations_for_index(index_name)[StoreOperations::TruncateIndex].call(db)
    end

    def has_index?(name)
      db.schema.tables.has_key?("#{name}_content")
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

    # Internal: return an Array of documents that match
    #
    # Returns Array of Documents
    def search_index(index_name, query)
      operations_for_index(index_name)[StoreOperations::QuerySearch].call(db, query)
    end

    # Internal: return the count of documents that match
    #
    # Returns integer
    def count_search_index(index_name, query)
      operations_for_index(index_name)[StoreOperations::QuerySearchCount].call(db, query)
    end

    def find_one_document_in_index(index_name, document)
      operations_for_index(index_name)[StoreOperations::FindOne].call(db, document)
    end

    def remove_document_from_index(index_name, document)
      operations_for_index(index_name)[StoreOperations::Delete].call(db, document)
    end

    def remove_documents_from_index(index_name, documents)
      operations_for_index(index_name)[StoreOperations::BulkDelete].call(db, documents)
    end

    def update_document_in_index(index_name, document)
      operations_for_index(index_name)[StoreOperations::Update].call(db, document)
    end

    private

    def operations_for_index(index_name)
      @index_operations[index_name] || {
        StoreOperations::CreateIndex   => StoreOperations::CreateIndex.new(index_name),
        StoreOperations::DropIndex     => StoreOperations::DropIndex.new(index_name),
        StoreOperations::TruncateIndex => StoreOperations::TruncateIndex.new(index_name),
        StoreOperations::Insert        => StoreOperations::Insert.new(index_name),
        StoreOperations::BulkInsert    => StoreOperations::BulkInsert.new(index_name),
        StoreOperations::DocumentCount => StoreOperations::DocumentCount.new(index_name),
        StoreOperations::QuerySearch   => StoreOperations::QuerySearch.new(index_name),
        StoreOperations::QuerySearchCount  => StoreOperations::QuerySearchCount.new(index_name),
        StoreOperations::FindOne       => StoreOperations::FindOne.new(index_name),
        StoreOperations::Delete        => StoreOperations::Delete.new(index_name),
        StoreOperations::BulkDelete    => StoreOperations::BulkDelete.new(index_name),
        StoreOperations::Update        => StoreOperations::Update.new(index_name),
      }
    end
  end
end

require 'thin_search/store_operations'
