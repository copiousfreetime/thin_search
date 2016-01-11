require 'test_helper'
require 'thin_search/query_expression/token'

class TestToken < ::Minitest::Test
  def test_double_quoted_string_is_quoted
    t = ThinSearch::QueryExpression::Token.new('"token"')
    assert(t.quoted?)
  end

  def test_double_quoted_string_has_quote_mark
    t = ThinSearch::QueryExpression::Token.new('"token"')
    assert_equal('"', t.quote_mark)
  end

  def test_double_value_is_unquoted
    t = ThinSearch::QueryExpression::Token.new('"token"')
    assert_equal("token", t.value)
    assert_equal(false, ThinSearch::QueryExpression::Token.quoted?(t.value))
  end

  def test_single_quoted_string_is_quoted
    t = ThinSearch::QueryExpression::Token.new("'token'")
    assert(t.quoted?)
  end

  def test_single_quoted_string_has_quote_mark
    t = ThinSearch::QueryExpression::Token.new("'token'")
    assert_equal("'", t.quote_mark)
  end

  def test_single_value_is_unquoted
    t = ThinSearch::QueryExpression::Token.new("'token'")
    assert_equal("token", t.value)
    assert_equal(false, ThinSearch::QueryExpression::Token.quoted?(t.value))
  end

  def test_unquoted_is_not_quoted
    t = ThinSearch::QueryExpression::Token.new("token")
    refute(t.quoted?)
    assert_nil(t.quote_mark)
  end

  def test_single_quoted
    t = ThinSearch::QueryExpression::Token.new("token")
    assert_equal("'token'", t.single_quoted)
  end

  def test_double_quoted
    t = ThinSearch::QueryExpression::Token.new("token")
    assert_equal('"token"', t.double_quoted)
  end

  def test_embedded_double_within_double_quotes
    t = ThinSearch::QueryExpression::Token.new("tok\"en")
    assert_equal('"tok""en"', t.double_quoted)
  end

  def test_embedded_single_within_double_quotes
    t = ThinSearch::QueryExpression::Token.new("tok'en")
    assert_equal('"tok\'en"', t.double_quoted)
  end

  def test_embedded_single_within_single_quotes
    t = ThinSearch::QueryExpression::Token.new("tok'en")
    assert_equal("'tok''en'", t.single_quoted)
  end

  def test_embedded_double_within_single_quotes
    t = ThinSearch::QueryExpression::Token.new('tok"en')
    assert_equal("'tok\"en'", t.single_quoted)
  end
end

