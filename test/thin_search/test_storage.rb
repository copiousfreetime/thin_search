require 'test_helper'
require 'thin_search/store'
require 'securerandom'

class TestStorage < ::ThinSearch::Test
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
    doc = ::ThinSearch::Document.new do |d|
      d.context    = "test_storage_context"
      d.context_id = SecureRandom.uuid
      d.facets     = { :date => "2015-05-01", :colour => "blue" }
      d.important  = %w[ some key words ]
      d.normal     = %w[ some other data that is less imporant ]
    end

    store.add_document_to_index(index_name, doc)
    assert(store.db.row_changes == 1)
  end

  def test_counts_documents
    doc = ::ThinSearch::Document.new do |d|
      d.context    = "test_storage_context"
      d.context_id = SecureRandom.uuid
      d.facets     = { :date => "2015-05-01", :colour => "blue" }
      d.important  = %w[ some key words ]
      d.normal     = %w[ some other data that is less imporant ]
    end
    count = store.document_count_for(index_name)
    assert(count == 0)
    store.add_document_to_index(index_name, doc)
    count = store.document_count_for(index_name)
    assert(count == 1)
  end
end
