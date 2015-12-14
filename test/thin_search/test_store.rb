require 'test_helper'
require 'thin_search/store'
require 'securerandom'

class TestStore < ::ThinSearch::Test
  attr_reader :index_name

  def setup
    super
    @index_name = "test_storage"
    store.create_index(index_name)
  end

  def test_creates_storage_index
    assert(store.has_index?(index_name))
  end

  def test_deletes_storage_index
    assert(store.has_index?(index_name))
    store.drop_index(index_name)
    refute(store.has_index?(index_name), "#{index_name} exists")
  end

  def test_inserts_document
    store.add_document_to_index(index_name, fake_document)
    assert_equal(1, store.db.row_changes)
  end

  def test_counts_documents
    docs = Array.new(3) { fake_document }
    count = store.document_count_for(index_name)
    assert(count == 0)

    docs.each do |doc|
      store.add_document_to_index(index_name, doc)
    end

    count = store.document_count_for(index_name)
    assert_equal(docs.size, count)
  end

  def test_bulk_insert_documents
    docs = Array.new(10) { fake_document }

    count = store.document_count_for(index_name)
    assert_equal(0, count)

    store.add_documents_to_index(index_name, docs)

    count = store.document_count_for(index_name)
    assert_equal(docs.size, count, "Index Document count #{count} does not equal #{docs.size}")
  end

  def test_raises_exception_on_invalid_document
    doc = fake_document
    doc.context_id = nil

    error = assert_raises(::ThinSearch::Document::Error) { store.add_document_to_index(index_name, doc) }

    assert_match(/context_id must be set/, error.message)
  end

  def test_query_documents
    docs = Array.new(10) { fake_document }
    should_match = docs.select { |d| d.important.flatten.join(' ') =~ /gmail/ }

    store.add_documents_to_index(index_name, docs)
    results = Array.new
    store.search_index(index_name, "gmail") do |doc|
      results << doc
    end
    assert_equal(should_match.size, results.size)
  end

  def test_find_one_document
    docs = Array.new(3) { fake_document }
    store.add_documents_to_index(index_name, docs)
    find_me = docs.last.dup
    doc = store.find_one_document_in_index(index_name,find_me)
    assert_nil(find_me.rowid)
    assert_equal(find_me.context, doc.context)
    assert_equal(find_me.context_id, doc.context_id)
    refute_nil(doc.rowid)
  end

  def test_remove_document
    docs = Array.new(10) { fake_document }

    count = store.document_count_for(index_name)
    assert(0, count)

    store.add_documents_to_index(index_name, docs)
    count = store.document_count_for(index_name)
    assert_equal(docs.size, count)

    store.remove_document_from_index(index_name, docs.first)
    count = store.document_count_for(index_name)
    assert_equal(docs.size - 1, count)
  end
end
