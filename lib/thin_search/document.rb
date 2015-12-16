require 'thin_search/error'
module ThinSearch
  # Document is the object that is stored and returned from all indexes
  class Document
    class Error < ::ThinSearch::Error ; end
    attr_accessor :context
    attr_accessor :context_id
    attr_accessor :facets
    attr_accessor :important
    attr_accessor :normal
    attr_accessor :rowid
    attr_accessor :rank

    def initialize(data = {}, &block)
      @context    = data[:context]    || data['context']
      @context_id = data[:context_id] || data['context_id']
      @facets     = data[:facets]     || data['facets']
      @important  = data[:important]  || data['important']
      @normal     = data[:normal]     || data['normal']
      @rowid      = data[:rowid]      || data['rowid']
      @rank       = data[:rank]       || data['rank']
      yield self if block_given?
    end

    def validate
      raise Error, "context must be set"    if context.nil?
      raise Error, "context_id must be set" if context_id.nil?
      true
    end

    def to_indexable_document
      self
    end

    def unique_index_id
      [ context, context_id ].join(".")
    end

    def valid?
      validate
    rescue ArgumentError
      false
    end

  end
end
