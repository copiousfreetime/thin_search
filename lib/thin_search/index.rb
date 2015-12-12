require 'amalgalite'
require 'thin_search/store'

module ThinSearch
  class Index
    DEFAULT_NAME = "search"

    attr_reader :store
    attr_reader :name

    def initialize(opts = {:store => nil, :name => DEFAULT_NAME})
      @store = opts.fetch(:store)
      @name  = opts.fetch(:name)

      @store.create_index(@name) unless @store.has_index?(@name)
    end
  end
end
