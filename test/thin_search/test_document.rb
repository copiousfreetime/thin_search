require 'test_helper'
require 'thin_search/document'
require 'securerandom'

class TestDocument < ::ThinSearch::Test
  def test_raises_error_for_invalid_context
    doc = ::ThinSearch::Document.new
    error = assert_raises(::ThinSearch::Document::Error) { doc.validate }
    assert_equal("context must be set", error.message)
  end

  def test_raises_error_for_invalid_context_id
    doc = ::ThinSearch::Document.new( :context => self.class.name )
    error = assert_raises(::ThinSearch::Document::Error) { doc.validate }
    assert_equal("context_id must be set", error.message)
  end

  def test_create_document_via_yield
    uuid = SecureRandom.uuid
    doc = ::ThinSearch::Document.new( :context => self.class.name ) do |d|
      d.context_id = uuid
      d.facets     = { :foo => "bar" }
      d.important  = %w[ important stuff ]
      d.normal     = %w[ other things ]
    end

    refute( doc.context_id.nil? )
    assert_equal("bar", doc.facets[:foo])
    assert_equal(%w[ important stuff ],  doc.important)
    assert_equal(%w[ other things ],  doc.normal)
    assert_equal("TestDocument.#{uuid}", doc.index_unique_id)
  end
end
