require 'amalgalite'
require 'pathname'
require 'thin_search/document'

module ThinSearch
  class Store
    attr_reader :db

    def initialize(path)
      @db        = ::Amalgalite::Database.new(path.to_s)
      @sql_cache = {}
    end

    def create_index(name)
      db.execute(<<-SQL)
      CREATE VIRTUAL TABLE #{name} USING fts5(
            context    ,
            context_id ,
            facets,
            important,
            normal,
            tokenize = 'porter unicode61'
      );
      SQL
    end

    def drop_index(name)
      db.execute("DROP TABLE #{name}")
    end

    def has_index?(name)
      db.schema.tables.has_key?(name)
    end

    def add_document_to_index(index_name, document)
      add_documents_to_index(index_name, Array(document))
    end

    def add_documents_to_index(index_name, documents)
      insertion_transaction(index_name) do |statement|
        documents.each do |document|
          statement.execute(doc_to_insert_bindings(document))
        end
      end
    end

    def document_count_for(index_name)
      db.first_value_from("SELECT count(*) FROM #{index_name}")
    end

    private

    def insertion_transaction(index_name, &block)
      db.transaction do |db_in_transaction|
        db_in_transaction.prepare(insert_sql(index_name)) do |stmt|
          yield stmt
        end
      end
    end

    def doc_to_insert_bindings(doc)
      {
        ':context'    => doc.context,
        ':context_id' => doc.context_id,
        ':facets'     => doc.facets.to_json,
        ':important'  => indexable_string(doc.important),
        ':normal'     => indexable_string(doc.normal)
      }
    end

    def indexable_string( thing )
      [ thing ].flatten.compact.join(' ')
    end

    def insert_sql(index_name)
      @sql_cache["#{index_name}.insert"] ||= <<-SQL
      INSERT INTO #{index_name} (context, context_id, facets, important, normal )
      VALUES (:context, :context_id, json(:facets), :important, :normal);
      SQL
    end
  end
end
