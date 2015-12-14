require 'amalgalite'
require 'pathname'
require 'thin_search/document'
require 'thin_search/store_operations'

module ThinSearch
  class Store
    attr_reader :db

    def initialize(path)
      @db = ::Amalgalite::Database.new(path.to_s)
    end

    def create_index(index_name)
      StoreOperations::CreateIndex.new(index_name).call(db)
    end

    def drop_index(index_name)
      StoreOperations::DropIndex.new(index_name).call(db)
    end

    def has_index?(name)
      db.schema.tables.has_key?(name)
    end

    def add_document_to_index(index_name, document)
      operation = StoreOperations::Insert.new(index_name)
      operation.call(db, document)
    end

    def add_documents_to_index(index_name, documents)
      operation = StoreOperations::BulkInsert.new(index_name)
      operation.call(db, documents)
    end

    def document_count_for(index_name)
      operation = StoreOperations::DocumentCount.new(index_name)
      operation.call(db)
    end

    def search_index(index_name, query, &block)
      operation = StoreOperations::Search.new(index_name)
      operation.call(db, query) do |document|
        yield document
      end
    end

    def document_to_select_rowid_bindings(doc)
      {
        ':query'      => "'\"context:#{doc.context} AND context_id:#{doc.context_id}\"'",
        ':context'    => doc.context,
        ':context_id' => doc.context_id,
      }
    end

    def select_rowid_sql(index_name)
      @sql_cache["#{index_name}.select_rowid"] || <<-SQL
      SELECT rowid, *
        FROM #{index_name}
       WHERE #{index_name} MATCH :query
         AND context = :context
         AND context_id = :context_id
      SQL
    end

    def delete_sql(index_name)
      @sql_cache["#{index_name}.delete"] ||<<-SQL
      DELETE FROM #{index_name}
       WHERE rowid = ?
      SQL
    end
  end
end

require 'thin_search/store_operations'
