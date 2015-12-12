require 'test_helper'
require 'thin_search/store'

class TestStorage < ::Minitest::Test
  def setup
    @db_path = TestPaths.test_db
    @store   = ::ThinSearch::Store.new(@db_path)
  end

  def teardown
    File.unlink(@db_path) if File.exist?(@db_path)
  end

  def test_creates_storage_index
    @store.create_index("test_storage")
    assert(@store.has_index?("test_storage"))
  end

  def test_deletes_storage_index
    @store.create_index("test_storage")
    assert(@store.has_index?("test_storage"))
    @store.drop_index("test_storage")
    refute(@store.has_index?("test_storage"), "test_storage exists")
  end

end
