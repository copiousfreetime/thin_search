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

    assert_equal(expected.size, result.size)
  end

  def test_query_search_default_index
    query = ThinSearch::Query.new("gmail", :index => index)
    assert_equal(index, query.default_index)
  end

  def test_query_overrides_default_index
    index2      = ::ThinSearch::Index.new(:store => store, :name => "test_2_index")
    collection2 = TestModel.generate_collection(50)
    index2.add(collection2.values)

    expected    = collection2.values.select { |doc| doc.email =~ /gmail/ }
    query       = ThinSearch::Query.new("gmail", :index => index)

    result = query.result
    result2 = query.result(index2)

    refute_equal(result.size, result2.size)
    assert_equal(expected.size, result2.size)
  end

  def test_query_limits_to_per_page
    query = ThinSearch::Query.new("gmail").paginate(:per_page => 1)
    result = query.execute(index)
    assert_equal(1, result.size)
  end

  def test_query_skips_to_designated_page
    expected    = docs.select { |doc| doc.email =~ /gmail/ }
    all_query   = ThinSearch::Query.new("gmail")
    all_results = all_query.execute(index)

    page_1 = all_query.paginate(:per_page => 2, :page => 1).execute(index)
    assert_equal(expected.shift(2).size, page_1.size)

    expected_ids = all_results.raw_documents[0..1].map(&:context_id)
    assert_equal(expected_ids, page_1.raw_documents.map(&:context_id))

    page_2 = all_query.paginate(:per_page => 2, :page => 2).execute(index)
    assert_equal(expected.shift(2).size, page_2.size)

    expected_ids = all_results.raw_documents[2..3].map(&:context_id)
    assert_equal(expected_ids, page_2.raw_documents.map(&:context_id))
  end

end
