require 'test_helper'
require 'thin_search/document'

class TestDocument < ::ThinSearch::Test
  def test_raises_error_for_invalid_context
    doc = ::ThinSearch::Document.new
    error = assert_raises(ArgumentError) { doc.validate }
    assert(error.message == "context must be set", "Wrong message")
  end

  def test_raises_error_for_invalid_context
    doc = ::ThinSearch::Document.new( :context => self.class.name )
    error = assert_raises(ArgumentError) { doc.validate }
    assert(error.message == "context_id must be set", "Wrong message")
  end
end
