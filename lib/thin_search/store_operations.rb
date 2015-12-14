require 'thin_search/store_operation'
module ThinSearch
  module StoreOperations
    class CreateIndex < StoreOperation
      def sql
        <<-SQL
        CREATE TABLE #{content_table}(
          rowid      INTEGER PRIMARY KEY AUTOINCREMENT,
          context    TEXT,
          context_id TEXT,
          facets     TEXT,
          important  TEXT,
          normal     TEXT
        );

        CREATE UNIQUE INDEX #{content_table}_idx
            ON #{content_table}(context, context_id);

        CREATE VIRTUAL TABLE #{search_table} USING fts5(
              context    ,
              context_id ,
              facets,
              important,
              normal,
              tokenize = 'porter unicode61',
              content = '#{content_table}',
              content_rowid = 'rowid'
        );

        INSERT INTO #{search_table}(#{search_table}, rank) VALUES('rank', 'bm25(1.0,1.0,1.0,10.0,2.0)');

        CREATE TRIGGER #{content_table}_after_insert_tgr AFTER INSERT ON #{content_table}
        BEGIN
          INSERT INTO #{search_table}(rowid, context, context_id, facets, important, normal)
               VALUES (new.rowid, new.context, new.context_id, new.facets, new.important, new.normal);
        END;

        CREATE TRIGGER #{content_table}_after_delete_tgr AFTER DELETE ON #{content_table}
        BEGIN
          INSERT INTO #{search_table}(#{search_table}, rowid, context, context_id, facets, important, normal)
               VALUES ('delete', old.rowid, old.context, old.context_id, old.facets, old.important, old.normal);
        END;

        CREATE TRIGGER #{content_table}_after_update_tgr AFTER UPDATE ON #{content_table}
        BEGIN
          INSERT INTO #{search_table}(#{search_table}, rowid, context, context_id, facets, important, normal)
               VALUES ('delete', old.rowid, old.context, old.context_id, old.facets, old.important, old.normal);
          INSERT INTO #{search_table}(rowid, context, context_id, facets, important, normal)
               VALUES (new.rowid, new.context, new.context_id, new.facets, new.important, new.normal);
        END;
        SQL
      end

      def call(db)
        db.execute_batch(sql)
      end
    end


    class DropIndex < StoreOperation
      def sql
        <<-SQL
        DROP TABLE #{search_table};
        DROP TABLE #{content_table};
        SQL
      end

      def call(db)
        db.execute_batch(sql)
      end
    end


    class Insert < StoreOperation
      def sql
        @sql ||= <<-SQL
        INSERT INTO #{content_table} (context, context_id, facets, important, normal )
        VALUES (:context, :context_id, json(:facets), :important, :normal)
        SQL
      end

      def call(db, document)
        document.validate
        sql_params = document_to_sql_bindings(document)
        db.execute(sql, sql_params)
      end

      private

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
        @sql ||= "SELECT count(*) FROM #{content_table}"
      end

      def call(db)
        db.first_value_from(sql)
      end
    end


    class Search < StoreOperation
      def sql
        @sql ||= <<-SQL
          SELECT *
            FROM #{search_table}
           WHERE #{search_table} MATCH ?
        ORDER BY rank
        SQL
      end

      def call(db, query)
        Enumerator.new do |yielder|
          db.execute(sql, query) do |row|
            yielder << document_from_row(row)
          end
        end
      end
    end


    class FindOne < StoreOperation
      def sql
        @sql ||= <<-SQL
         SELECT *
           FROM #{content_table}
          WHERE context = :context
            AND context_id = :context_id
        SQL
      end

      def call(db, document)
        rows = db.execute(sql, document_to_sql_bindings(document))
        if doc = rows.first then
          doc = document_from_row(doc)
        end
        doc
      end

      def document_to_sql_bindings(document)
        {
          ":context" => document.context,
          ":context_id" => document.context_id
        }
      end
    end


    class Delete < StoreOperation
      def sql
        @sql ||= <<-SQL
          DELETE FROM #{content_table}
           WHERE context = :context
             AND context_id = :context_id
        SQL
      end

      def call(db, document)
        db.execute(sql, document_to_sql_bindings(document))
      end

      def document_to_sql_bindings(document)
        {
          ":context" => document.context,
          ":context_id" => document.context_id
        }
      end
    end


    class BulkDelete < StoreOperation
      def initialize(index_name)
        @delete = Delete.new(index_name)
      end

      def call(db, documents)
        db.transaction do |transaction|
          transaction.prepare(@delete.sql) do |statement|
            documents.each do |document|
              @delete.call(transaction, document)
            end
          end
        end
      end
    end


    class Update < StoreOperation
      def sql
        @sql ||= <<-SQL
          UPDATE #{content_table}
             SET facets       = json(:facets)
                ,important    = :important
                ,normal       = :normal
           WHERE context = :context
             AND context_id = :context_id
        SQL
      end

      def call(db, document)
        db.execute(sql, document_to_sql_bindings(document))
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
  end
end
