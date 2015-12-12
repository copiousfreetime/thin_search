module ThinSearch
  # Document is the object that is stored and returned from all indexes
  class Document
    attr_accessor :context
    attr_accessor :context_id
    attr_accessor :facets
    attr_accessor :important
    attr_accessor :normal

    def initialize(data = {})
      @context    = data[:context]
      @context_id = data[:context_id]
    end

    def validate
      raise ArgumentError, "context must be set"    if context.nil?
      raise ArgumentError, "context_id must be set" if context_id.nil?
      true
    end

    def valid?
      validate
    rescue ArgumentError
      false
    end
  end
end
