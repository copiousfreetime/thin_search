require 'thin_search/document'

module ThinSearch
  # Internal: common class for Store operations
  #
  # This class is only used by Store and StoreOperations
  class StoreOperation
    attr_reader :index_name

    def initialize(index_name)
      @index_name = index_name
    end

    def document_from_row(row)
      ::ThinSearch::Document.new do |doc|
        doc.context    = row["context"]
        doc.context_id = row["context_id"]
        doc.facets     = JSON.parse(row["facets"])
        doc.important  = row["important"]
        doc.normal     = row["normal"]
        doc.rowid      = row["rowid"]
      end
    end
  end
end

