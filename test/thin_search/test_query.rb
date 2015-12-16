require 'test_helper'
require 'test_model'
require 'thin_search/index'
require 'thin_search/conversion'
require 'thin_search/query'

class TestQuery < ::ThinSearch::Test

  attr_reader :index
  attr_reader :index_name
  attr_reader :docs

  def setup
    super
    ::ThinSearch::Conversion.register({
      :context    => "TestModel",
      :context_id => :id,
      :finder     => :find_by_id,
      :facets     => :thinsearch_facets,
      :important  => :thinsearch_important,
      :normal     => :thinsearch_normal,
    }
    )

    TestModel.populate(10)
    @docs       = TestModel.collection.values
    @index_name = "test_index"
    @index      = ::ThinSearch::Index.new(:store => store, :name => @index_name)
    @index.add(@docs)
  end

  def teardown
    super
    TestModel.clear
    ThinSearch::Conversion.registry.clear
  end

  def test_search_returns_results
    expected = docs.select { |doc| doc.email =~ /gmail/ }
    query = ThinSearch::Query.new("gmail")
    result = query.result(index)

    assert(expected.size, result.size)
  end

  # def test_search_returns_an_array_if_no_block
  #   expected = docs.select { |doc| doc.email =~ /gmail/ }
  #   query = index.search("gmail")
  #   assert_equal(expected.size, list.size)
  # end


end
