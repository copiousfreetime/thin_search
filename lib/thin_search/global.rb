require 'thin_search/error'
require 'thin_search/store'
require 'thin_search/index'
require 'thin_search/railtie'
require 'pathname'

module ThinSearch
  # Public: Global configuration for thin search
  #
  # Some systems would like to have a global location for holding a single
  # store and index that can be accessed from anywhere. This is a resource that
  # may be used by those who want to do this.
  #
  # Global also holds the path calculation for the root database should that be
  # use. Which if you are using Rails it probably is.
  #
  # Global configuration is done via 2 environment variables
  #
  # THIN_SEARCH_ROOT - a directory that is the root of thin search file storage
  # THIN_SEARCH_DB   - the full path to the database. This does not need to be
  #                    set. Generally you will use this to override the search 
  #                    database location.
  module Global
    class Error < ::ThinSearch::Error ; end

    THIN_SEARCH_ROOT_ENV = "THIN_SEARCH_ROOT"
    THIN_SEARCH_DB_ENV   = "THIN_SEARCH_DB"

    @store      = nil
    @index      = nil
    @root_path  = nil
    @db_path    = nil

    # Public: The calculation of the default root path
    #
    # This is the fallback location of where to set the root path if no
    # environment variable is set. There are 3 possible cases we deal with at
    # the moment:
    #
    # 1) we are a rails app: rails.root + db/thin_search-#{rails
    # 2) we are a rails app that is deployed : cap root +
    # shared/db/thin_search-rails
    # 3) everything else
    def self.default_root
      if rails? then
        if ::ThinSearch::Railtie.is_cap_deploy? then
          File.join(::ThinSearch::Railtie.cap_path, "shared/db/thin_search")
        else
          File.join(Rails.root, "db/thin_search")
        end
      else
        Dir.pwd
      end
    end

    # Public: Access to the global root path for thin_search
    #
    def self.root_path
      @root_path ||= Pathname.new(ENV.fetch(THIN_SEARCH_ROOT_ENV) { default_root })
    end

    # Public: The path to the thin_search database.
    #
    # If THIN_SEARCH_DB is set, then it will use that directly. Otherwise it is
    # relative to the #root_path
    #
    def self.db_path
      basename = rails? ? "thin_search-#{Rails.env}.db" : "thin_search.db"
      @db_path ||= Pathname.new(ENV.fetch(THIN_SEARCH_DB) { File.join(root_path, basename) })
    end

    # Public: Access to a global ::ThinSearch::Store
    #
    def self.store
      @store ||= ::ThinSearch::Store.new(db_path)
      @store
    end

    def self.index
      @index ||= ::ThinSearch::Index.new(:store => store, :name => ::ThinSearch::Index::DEFAULT_NAME)
    end

    def self.rails?
      defined?(::ThinSearch::Railtie)
    end
  end
end
