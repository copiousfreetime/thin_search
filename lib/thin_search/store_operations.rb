require 'thin_search/store_operation'
module ThinSearch
  module StoreOperations
    class CreateIndex < StoreOperation
      def sql
        <<-SQL
        CREATE VIRTUAL TABLE #{index_name} USING fts5(
              context    ,
              context_id ,
              facets,
              important,
              normal,
              tokenize = 'porter unicode61'
        )
        SQL
      end

      def call(db)
        db.execute(sql)
      end
    end


    class DropIndex < StoreOperation
      def sql
        "DROP TABLE #{index_name}"
      end

      def call(db)
        db.execute(sql)
      end
    end


    class Insert < StoreOperation
      def sql
        @sql ||= <<-SQL
        INSERT INTO #{index_name} (context, context_id, facets, important, normal )
        VALUES (:context, :context_id, json(:facets), :important, :normal)
        SQL
      end

      def call(db, document)
        document.validate
        sql_params = document_to_sql_bindings(document)
        db.execute(sql, sql_params)
      end

      private

      def indexable_string( thing )
        [ thing ].flatten.compact.join(' ')
      end

      def document_to_sql_bindings(document)
        {
          ":context"    => document.context,
          ":context_id" => document.context_id,
          ":facets"     => document.facets.to_json,
          ":important"  => indexable_string(document.important),
          ":normal"     => indexable_string(document.normal)
        }
      end
    end


    class BulkInsert < StoreOperation
      def initialize(index_name)
        @insert = Insert.new(index_name)
      end

      def call(db, documents)
        db.transaction do |transaction|
          transaction.prepare(@insert.sql) do |statement|
            documents.each do |document|
              @insert.call(transaction, document)
            end
          end
        end
      end
    end


    class DocumentCount < StoreOperation
      def sql
        @sql ||= "SELECT count(*) FROM #{index_name}"
      end

      def call(db)
        db.first_value_from(sql)
      end
    end


    class Search < StoreOperation
      def sql
        @sql ||= "SELECT * FROM #{index_name} WHERE #{index_name} MATCH ?"
      end

      def call(db, query, &block)
        db.execute(sql, query) do |row|
          yield document_from_row(row)
        end
      end
    end
  end
end
