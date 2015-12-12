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

    assert(count == 1)
  end

  def test_can_index_multiple_documents
    docs = Array.new(10) { fake_document }
    index.add(docs)
    count = store.document_count_for(index_name)
    assert(count == docs.count)
  end

  end
end
