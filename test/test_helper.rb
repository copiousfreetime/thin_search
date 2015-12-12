require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

class TestPaths
  def self.root_dir
    @root_dir ||= (
      path_parts = ::File.expand_path(__FILE__).split(::File::SEPARATOR)
      lib_index  = path_parts.rindex("test")
      path_parts[0...lib_index].join(::File::SEPARATOR) + ::File::SEPARATOR
    )
    return @root_dir
  end

  def self.lib_path(*args)
    self.sub_path("lib", *args)
  end

  def self.test_path(*args)
    self.sub_path("test", *args)
  end

  def self.tmp_path(*args)
    tmp = self.sub_path("tmp", *args)
    File.mkdir_p(tmp)
    return tmp
  end

  def self.sub_path(sub,*args)
    sp = ::File.join(root_dir, sub) + File::SEPARATOR
    sp = ::File.join(sp, *args) if args
  end

  def self.test_db
    test_path("test.db")
  end
end

module ThinSearch
  class Test < ::Minitest::Test

    attr_reader :db_path
    attr_reader :store

    def setup
      @db_path = TestPaths.test_db
    end

    def teardown
      File.unlink(@db_path) if File.exist?(@db_path)
    end

    def store
      @store   ||= ::ThinSearch::Store.new(@db_path)
    end
  end
end
