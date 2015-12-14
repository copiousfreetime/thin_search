require 'test_helper'
require 'thin_search/store'
require 'thin_search/index'

class TestIndex < ::ThinSearch::Test

  attr_reader :index
  attr_reader :index_name
  attr_reader :docs

  def setup
    super
    @index_name = "test_index"
    @index      = ::ThinSearch::Index.new(:store => store, :name => @index_name)
    @docs       = Array.new(10) { fake_document }
    @index.add(@docs)
  end

  def test_creates_index_on_instantiation
    assert(store.has_index?(index_name), "#{index_name} is missing")
  end

  def test_can_index_a_document
    before_count = store.document_count_for(index_name)
    index.add(fake_document)
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

    assert_equal(find_me.context, doc.context)
    assert_equal(find_me.context_id, doc.context_id)
  end

  def test_can_update_a_document
    find_me = docs.last
    normal  = "testupdatesdocument"
    find_me.normal = normal

    index.update(find_me)
    doc = index.find(find_me)
    assert_equal(find_me.context, doc.context)
    assert_equal(find_me.context_id, doc.context_id)
  end
end
