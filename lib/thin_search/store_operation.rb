require 'thin_search/document'
require 'thin_search/query'

require 'digest'

module ThinSearch
  # Internal: common class for Store operations
  #
  # This class is only used by Store and StoreOperations
  class StoreOperation
    attr_reader :index_name
    attr_reader :content_table
    attr_reader :search_table

    def initialize(index_name)
      @index_name    = index_name
      @search_table  = "#{index_name}_fts"
      @content_table = "#{index_name}_content"
    end

    def document_from_row(row)
      ::ThinSearch::Document.new do |doc|
        doc.context    = row["context"]
        doc.context_id = row["context_id"]
        doc.facets     = JSON.parse(row["facets"])
        doc.important  = row["important"]
        doc.normal     = row["normal"]
        doc.rowid      = row["rowid"]
        doc.rank       = row["rank"]
      end
    end

    def indexable_string( thing )
      [ thing ].flatten.compact.join(' ')
    end

    def make_query( thing )
      return thing if thing.instance_of?(Query)
      Query.new(thing)
    end
  end
end

