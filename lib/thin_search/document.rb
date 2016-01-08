require 'thin_search/error'
require 'digest/md5'
module ThinSearch
  # Document is the object that is stored and returned from all indexes
  class Document
    class Error < ::ThinSearch::Error ; end
    attr_accessor :context
    attr_accessor :context_id
    attr_accessor :facets
    attr_reader   :exact
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
      @exact      = calculate_exact(data[:exact] || data['exact'])
      yield self if block_given?
    end

    def exact=(val)
      @exact = calculate_exact(val)
    end

    def validate
      raise Error, "context must be set"    if context.nil?
      raise Error, "context_id must be set" if context_id.nil?
      true
    end

    def to_indexable_document
      self
    end

    def index_unique_id
      [ context, context_id ].join(".")
    end

    def valid?
      validate
    rescue ArgumentError
      false
    end

    private
    def calculate_exact(xact)
      case xact
      when String
        Digest::MD5.hexdigest(xact.strip)
      when Array
        xact.map { |thing| Digest::MD5.hexdigest(thing.strip) }
      else
        nil
      end
    end
  end
end
