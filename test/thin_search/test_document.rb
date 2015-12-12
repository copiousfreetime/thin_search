require 'test_helper'
require 'thin_search/document'
require 'securerandom'

class TestDocument < ::ThinSearch::Test
  def test_raises_error_for_invalid_context
    doc = ::ThinSearch::Document.new
    error = assert_raises(::ThinSearch::Document::Error) { doc.validate }
    assert(error.message == "context must be set", "Wrong message")
  end

  def test_raises_error_for_invalid_context_id
    doc = ::ThinSearch::Document.new( :context => self.class.name )
    error = assert_raises(::ThinSearch::Document::Error) { doc.validate }
    assert(error.message == "context_id must be set", "Wrong message")
  end

  def test_create_document_via_yield
    doc = ::ThinSearch::Document.new( :context => self.class.name ) do |d|
      d.context_id = SecureRandom.uuid
      d.facets     = { :foo => "bar" }
      d.important  = %w[ important stuff ]
      d.normal     = %w[ other things ]
    end

    refute( doc.context_id.nil? )
    assert( doc.facets[:foo] == "bar" )
    assert( doc.important == [ "important", "stuff" ] )
    assert( doc.normal == [ "other", "things" ] )

  end
end
