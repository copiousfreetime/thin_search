require 'amalgalite'
require 'pathname'

module ThinSearch
  class Store
    attr_reader :db

    def initialize(path)
      @db = ::Amalgalite::Database.new(path.to_s)
    end

    def create_index(name)
      db.execute(<<-SQL)
      CREATE VIRTUAL TABLE #{name} USING fts5(
            context    ,
            context_id ,
            facets,
            keywords,
            fulltext,
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
  end
end
