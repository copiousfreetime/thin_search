require 'test_helper'
require 'test_model'
require 'thin_search/index'
require 'thin_search/indexable'
require 'thin_search/query'
require 'thin_search/query_result'


class TestQueryResult < ::ThinSearch::Test

  class TestModel2 < TestModel
    Collection = Hash.new
    include ::ThinSearch::Indexable

    indexable :context_id => :id,
      :finder       => lambda { |i| TestModel2::Collection[i] },
      :batch_finder => lambda { |ids| ids.map { |i| TestModel2::Collection[i] } },
      :facets       => :thinsearch_facets,
      :important    => :thinsearch_important,
      :normal       => :thinsearch_normal,
      :exact        => :thinsearch_exact
  end

  class TestModel3 < TestModel
    Collection = Hash.new
    include ::ThinSearch::Indexable

    indexable :context_id => :id,
      :finder       => lambda { |i| TestModel3::Collection[i] },
      :batch_finder => lambda { |ids| ids.map { |i| TestModel3::Collection[i] } },
      :facets       => :thinsearch_facets,
      :important    => :thinsearch_important,
      :normal       => :thinsearch_normal,
      :exact        => :thinsearch_exact
  end

  attr_reader :collection_1
  attr_reader :collection_2

  def setup
    super
    TestModel2::Collection.clear
    TestModel2::Collection.merge!(TestModel2.generate_collection(10))

    TestModel3::Collection.clear
    TestModel3::Collection.merge!(TestModel3.generate_collection(10))

    @index_name = "test_query_result_index"
    @index      = ::ThinSearch::Index.new(:store => store, :name => @index_name)
    @index.add(TestModel2::Collection.values)
    @index.add(TestModel3::Collection.values)
    @query = @index.search("gmail")
  end

  def test_inflates_to_models
    result = @query.execute
    models = result.models
    models.each do |m|
      assert([::TestQueryResult::TestModel2, ::TestQueryResult::TestModel3].include?(m.class))
    end
  end

end

