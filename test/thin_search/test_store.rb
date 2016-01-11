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

  def test_creates_path_to_database
    refute(testing_tmp_path.exist?)
    db_path = testing_tmp_path.join("junk.db")
    ::ThinSearch::Store.new(db_path)
    assert(testing_tmp_path.exist?)
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
    results = store.search_index(index_name, "gmail")
    assert_equal(should_match.size, results.size)
  end

  def test_query_count_documents
    docs = Array.new(10) { fake_document }
    should_match = docs.select { |d| d.important.flatten.join(' ') =~ /gmail/ }

    store.add_documents_to_index(index_name, docs)
    count = store.count_search_index(index_name, "gmail")
    assert_equal(should_match.size, count)
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

  def test_bulk_remove_documents
    docs = Array.new(10) { fake_document }

    count = store.document_count_for(index_name)
    assert(0, count)

    store.add_documents_to_index(index_name, docs)
    count = store.document_count_for(index_name)
    assert_equal(docs.size, count)

    removing = docs.shift(5)
    store.remove_documents_from_index(index_name, removing)
    count = store.document_count_for(index_name)
    assert_equal(docs.size, count)
  end

  def test_update_document
    docs = Array.new(10) { fake_document }
    count = store.document_count_for(index_name)
    assert(0, count)

    store.add_documents_to_index(index_name, docs)
    count = store.document_count_for(index_name)
    assert_equal(docs.size, count)

    find_me = docs.last.dup
    doc = store.find_one_document_in_index(index_name, find_me)
    doc.important = "testupdatedocument"
    store.update_document_in_index(index_name, doc)
    doc2 = store.find_one_document_in_index(index_name, find_me)
    assert_equal("testupdatedocument", doc2.important)
  end

  def test_search_returns_ranked_documents
    normal_doc    = fake_document
    normal_doc.important = "normal"
    normal_doc.normal  = %w[ important important imporant ]
    store.add_document_to_index(index_name, normal_doc)

    important_doc = fake_document
    important_doc.important = "important"
    store.add_document_to_index(index_name, important_doc)

    list = store.search_index(index_name, "important")
    first = list.shift
    assert_equal(important_doc.context_id, first.context_id)

    second = list.shift
    assert_equal(normal_doc.context_id, second.context_id)
  end

  def test_search_returns_exact_as_highest_rank
    normal_doc           = fake_document
    normal_doc.normal    = %w[ exact exact exact ]
    normal_doc.important = "normal"
    normal_doc.exact     = "normal"
    store.add_document_to_index(index_name, normal_doc)

    important_doc           = fake_document
    important_doc.normal    = %w[ document document ]
    important_doc.important = "exact"
    important_doc.exact     = "important"
    store.add_document_to_index(index_name, important_doc)

    exact_doc           = fake_document
    exact_doc.normal    = %w[ best best ]
    exact_doc.important = "important"
    exact_doc.exact     = "exact"
    store.add_document_to_index(index_name, exact_doc)

    list = store.search_index(index_name, "exact")

    first = list.shift
    assert_equal(exact_doc.context_id, first.context_id)

    second = list.shift
    assert_equal(important_doc.context_id, second.context_id)

    third = list.shift
    assert_equal(normal_doc.context_id, third.context_id)

  end

  def test_truncates_index
    docs = Array.new(10) { fake_document }
    store.add_documents_to_index(index_name, docs)
    before = store.document_count_for(index_name)
    assert_equal(docs.size, before)

    store.truncate_index(index_name)
    after = store.document_count_for(index_name)
    assert_equal(0, after)
  end

  def test_count_search_index
    docs = Array.new(10) { fake_document }
    should_match = docs.select { |d| d.important.flatten.join(' ') =~ /gmail/ }

    store.add_documents_to_index(index_name, docs)
    count = store.count_search_index(index_name, "gmail")
    assert_equal(should_match.size, count)
  end

  def test_search_finds_email
    docs = Array.new(100) { fake_document }
    should_match = docs.select { |d| d.important.flatten.join(' ') =~ /gmail/ }
    store.add_documents_to_index(index_name, docs)

    count = store.count_search_index(index_name, "@gmail.com")
    assert_equal(should_match.size, count)
  end
end
