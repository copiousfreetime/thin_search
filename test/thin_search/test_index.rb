require 'test_helper'
require 'thin_search/store'
require 'thin_search/index'

class TestIndex < ::ThinSearch::Test

  attr_reader :index
  attr_reader :index_name

  def setup
    super
    @index_name = "test_index"
    @index      = ::ThinSearch::Index.new(:store => store, :name => @index_name)
  end

  def test_creates_index_on_instantiation
    assert(store.has_index?(index_name), "#{index_name} is missing")
  end

  def test_can_index_a_document
    index.add(fake_document)
    count = store.document_count_for(index_name)

    assert_equal(1, count)
  end

  def test_can_index_multiple_documents
    docs = Array.new(10) { fake_document }
    index.add(docs)
    count = store.document_count_for(index_name)
    assert_equal(docs.count, count)
  end

  def test_can_count_documents
    docs = Array.new(10) { fake_document }
    index.add(docs)
    count = index.count
    assert_equal(docs.size, count)
  end

  def test_can_remove_a_document
    docs = Array.new(10) { fake_document }
    index.add(docs)
    count = index.count
    assert_equal(docs.size, count)

    index.remove(docs.first)
    count = index.count
    assert_equal(docs.size - 1, count)
  end

  def test_can_remove_multiple_documents
    docs = Array.new(10) { fake_document }
    index.add(docs)
    count = store.document_count_for(index_name)
    assert_equal(docs.count, count)

    removing = docs.shift(5)
    index.remove(removing)
    count = store.document_count_for(index_name)
    assert_equal(docs.count, count)
  end

end
