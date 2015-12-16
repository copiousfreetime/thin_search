module ThinSearch
  class QueryResult

    attr_reader :raw_documents
    attr_reader :query
    attr_reader :missing
    attr_reader :total_count

    def initialize(query, documents, total_count = nil)
      @query               = query
      @raw_documents       = documents
      @total_count         = total_count || @raw_documents.size
      @models              = []
      @missing             = []
      @ordered_index_ids   = []
      @grouped_context_ids = Hash.new { |h,k| h[k] = Array.new }
      @models_by_index_id  = Hash.new
      prep_for_inflation
    end

    # Public: Return the original objects that were indexed. 
    #
    # This will convert the search documents back to their original Model
    # objects. If there are problems converting some of the documents back, then
    # those original raw documents will be stored in #missing
    #
    # Returns Array of models
    def models
      inflate_and_order_models if @models.empty?
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

    def prep_for_inflation
      raw_documents.each do |document|
        @ordered_index_ids << document.index_unique_id
        @grouped_context_ids[document.context] << document.context_id
      end
    end

    def inflate_and_order_models
      inflate_models
      order_models
    end

    def inflate_models
      @grouped_context_ids.each do |context, context_ids|
        context_models = inflate_context(context, context_ids)
        context_models.each do |model|
          @models_by_index_id[model._thin_search_index_unique_id] = model
        end
      end
    end

    def inflate_context(context, context_ids)
      conversion = ::ThinSearch::Conversion.for(context)
      conversion.batch_find_by_ids(context_ids)
    end

    def order_models
      @ordered_index_ids.each do |index_unique_id|
        if model = @models_by_index_id[index_unique_id] then
          @models << model
        end
      end
    end
  end
end
