require 'test_helper'
require 'test_model'
require 'thin_search/index'
require 'thin_search/query'
require 'thin_search/query_result'

class TestModel2 < TestModel ; end

class TestQueryResult < ::ThinSearch::Test

  #* have an index option to return the Documents instead of the objects
  #* efficient inflation of large numbers of objects from Documents

  #* REsults needs to have .total_pages .num_pages .current_page .
  #* show documents, missing documents in original via _thinsearch_documents
  # * and use .models to inflate at the end.

  attr_reader :collection_1
  attr_reader :collection_2

  def setup
    @collection_1 = TestModel.generate_collection(10)
    @collection_2 = TestModel.generate_collection(5)

    ::ThinSearch::Conversion.register({
      :context    => "TestModel",
      :context_id => :id,
      :finder     => lambda { |i| @collection_1[i] },
      :facets     => :thinsearch_facets,
      :important  => :thinsearch_important,
      :normal     => :thinsearch_normal,
    })

    ::ThinSearch::Conversion.register({
      :context    => "TestModel2",
      :context_id => :id,
      :finder     => lambda { |i| @collection_2[i] },
      :facets     => :thinsearch_facets,
      :important  => :thinsearch_important,
      :normal     => :thinsearch_normal,
    })

    @docs_1 = @collection_1.values.map { |d| ::ThinSearch::Conversion.to_indexable_document(d) }
    @docs_2 = @collection_2.values.map { |d| ::ThinSearch::Conversion.to_indexable_document(d) }
  end

  def test_inflates_to_models
    result = ::ThinSearch::QueryResult.new(nil, @docs_1)
    models = result.models
    assert_equal(@collection_1.values, models)
  end

end

