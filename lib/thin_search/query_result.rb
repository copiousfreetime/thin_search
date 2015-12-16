module ThinSearch
  class QueryResult

    attr_reader :raw_documents
    attr_reader :query
    attr_reader :missing
    attr_reader :total_count

    def initialize(query, documents, total_count = nil)
      @query         = query
      @raw_documents = documents
      @total_count   = total_count || @row_documents.size
      @models        = []
      @missing       = []
    end

    # Public: Return the original objects that were indexed. 
    #
    # This will convert the search documents back to their original Model
    # objects. If there are problems converting some of the documents back, then
    # those original raw documents will be stored in #missing
    #
    # Returns Array of models
    def models
      inflate_models if @models.empty?
      @models
    end

    def size
      @raw_documents.size
    end

    def num_pages
      (total_count / query.per_page).ceil
    end

    def current_page
      query.page
    end

    private

    def inflate_models
      raw_documents.each do |document|
        begin
          @models << ::ThinSearch::Conversion.from_indexable_document(document)
        rescue Object
          @missing << document
        end
      end
    end
  end
end
