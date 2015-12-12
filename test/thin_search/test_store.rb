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
    assert(store.db.row_changes == 1)
  end

  def test_counts_documents
    docs = Array.new(3) { fake_document }
    count = store.document_count_for(index_name)
    assert(count == 0)

    docs.each do |doc|
      store.add_document_to_index(index_name, doc)
    end

    count = store.document_count_for(index_name)
    assert(count == docs.size)
  end

  def test_bulk_insert_documents

  end


end
