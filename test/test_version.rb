require 'test_helper'
require 'thin_search'

class TestVersion < ::Minitest::Test
  def test_version_constant_match
    assert_match(/\A\d+\.\d+\.\d+\Z/, ThinSearch::VERSION)
  end

  def test_version_string_match
    assert_match(/\A\d+\.\d+\.\d+\Z/, ThinSearch::VERSION.to_s)
  end
end
