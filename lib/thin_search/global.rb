require 'thin_search/error'
require 'thin_search/store'
require 'thin_search/index'

module ThinSearch
  # Public: Global configuration for thin search
  #
  # Some systems would like to have a global location for holding a single
  # store and index that can be accessed from anywhere. This is a resource that
  # may be used by those who want to do this.
  #
  module Global
    class Error < ::ThinSearch::Error ; end

    @path       = nil
    @store      = nil
    @index      = nil
    @index_name = nil
    @is_setup   = false

    # Public: Access to a global ::ThinSearch::Store
    #
    def self.store
      raise Error, "Global store not setup, please run ::ThinSearch::Global.setup" unless is_setup?
      @store
    end

    def self.index
      raise Error, "Global index not setup, please run ::ThinSearch::Global.setup" unless is_setup?
      @index
    end

    def self.path
      raise Error, "Global path not setup, please run ::ThinSearch::Global.setup" unless is_setup?
      @path
    end

    def self.is_setup?
      @is_setup
    end

    def self.setup( opts = {} )
      if !is_setup? then
        @path       = opts.fetch(:path)
        @store      = ::ThinSearch::Store.new(@path)
        @index_name = opts.fetch(:index_name, ::ThinSearch::Index::DEFAULT_NAME)
        @index      = ::ThinSearch::Index.new(:store => @store, :name => @index_name)
        @is_setup   = true
      end
    end
  end
end
