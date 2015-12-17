require 'forwardable'
module ThinSearch
  class QueryResult

    include Enumerable

    attr_reader :raw_documents
    attr_reader :query
    attr_reader :total_count
    attr_reader :models

    extend Forwardable
    def_delegator :@models, :each


    def initialize(query, documents, total_count = nil)
      @query               = query
      @raw_documents       = documents
      @total_count         = total_count || @raw_documents.size
      @models              = inflate_documents_to_models(raw_documents)
    end

    def each(&block)
      models.each(&block)
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

    def inflate_documents_to_models(documents)

     # Track the documents original order
      ordered_index_ids   = []
      grouped_context_ids = Hash.new { |h,k| h[k] = Array.new }

      documents.each do |document|
        ordered_index_ids << document.index_unique_id
        grouped_context_ids[document.context] << document.context_id
      end

     # Batch inflate the grouped ids efficiently
      models_by_index_id = inflate_models(grouped_context_ids)

      # Order the inflated models by the original order
      order_models(ordered_index_ids, models_by_index_id)
    end

    def inflate_models(grouped_context_ids)
      Hash.new.tap do |models_by_index_id|
        grouped_context_ids.each do |context, context_ids|
          context_models = inflate_context(context, context_ids)
          context_models.each do |model|
            models_by_index_id[model._thin_search_index_unique_id] = model
          end
        end
      end
    end

    def inflate_context(context, context_ids)
      conversion = ::ThinSearch::Conversion.for(context)
      conversion.batch_find_by_ids(context_ids)
    end

    def order_models(ordered_index_ids, models_by_index_id)
      Array.new.tap do |models|
        ordered_index_ids.each do |index_unique_id|
          if model = models_by_index_id[index_unique_id] then
            models << model
          end
        end
      end
    end

  end
end
