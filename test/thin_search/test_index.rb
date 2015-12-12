require 'test_helper'
require 'thin_search/store'
require 'thin_search/index'

class TestIndex < ::ThinSearch::Test
  def test_creates_index_on_instantiation
    ::ThinSearch::Index.new(:store => store, :name => "test_index")
    assert(store.has_index?("test_index"), "test_index is missing")
  end
end
