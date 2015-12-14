require 'test_helper'
require 'test_model'
require 'thin_search/store'
require 'thin_search/index'
require 'thin_search/conversion'

class TestIndex < ::ThinSearch::Test

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

  def test_creates_index_on_instantiation
    assert(store.has_index?(index_name), "#{index_name} is missing")
  end

  def test_can_index_a_document
    before_count = store.document_count_for(index_name)
    index.add(TestModel.new)
    after_count = store.document_count_for(index_name)

    assert_equal(1, after_count - before_count)
  end

  def test_can_index_multiple_documents
    count = store.document_count_for(index_name)

    assert_equal(docs.count, count)
  end

  def test_can_count_documents
    count = index.count
    assert_equal(docs.size, count)
  end

  def test_can_remove_a_document
    count = index.count
    assert_equal(docs.size, count)

    index.remove(docs.first)
    count = index.count
    assert_equal(docs.size - 1, count)
  end

  def test_can_remove_multiple_documents
    count = index.count
    assert_equal(docs.count, count)

    removing = docs.shift(5)
    index.remove(removing)
    count = index.count
    assert_equal(docs.count, count)
  end

  def test_can_find_a_single_document
    find_me = docs.last
    doc = index.find(find_me)

    assert_equal(find_me.class.to_s, doc.context)
    assert_equal(find_me.id, doc.context_id)
  end

  def test_can_update_a_document
    find_me = docs.last
    dept    = "testupdatesdocument"
    find_me.department = dept

    index.update(find_me)
    doc = index.find(find_me)
    assert_equal(find_me.class.to_s, doc.context)
    assert_equal(find_me.id, doc.context_id)
  end

  def test_search_yields_each_found_document
    expected = docs.select { |doc| doc.email =~ /gmail/ }

    found = []
    index.search("gmail").each do |doc|
      found << doc
    end

    assert(expected.size, found.size)
  end

  def test_search_returns_an_array_if_no_block
    expected = docs.select { |doc| doc.email =~ /gmail/ }
    list = index.search("gmail")
    assert_equal(expected.size, list.size)
  end
end
