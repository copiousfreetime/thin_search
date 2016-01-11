require 'test_helper'
require 'thin_search/query_expression'

class QueryExpressionTest < ::Minitest::Test
  def test_simple_expression
    qe = ThinSearch::QueryExpression.for("foo")
    assert_equal(["foo"], qe.tokens.map(&:to_s))
  end

  def test_with_sub_expressions
    qe = ThinSearch::QueryExpression.for("foo bar k:v 'foo bar' a = 'b c'")
    assert_equal(["foo", "bar", "foo bar"], qe.tokens.map(&:to_s))

    sub1 = ThinSearch::QueryExpression::SubExpression.new(ThinSearch::QueryExpression::Token.new("k"),
                                                           ":",
                                                          ThinSearch::QueryExpression::Token.new("v"))
    assert_equal(sub1, qe.expressions[0])

    sub2 = ThinSearch::QueryExpression::SubExpression.new(ThinSearch::QueryExpression::Token.new("a"),
                                                           "=",
                                                          ThinSearch::QueryExpression::Token.new("'b c'"))
    assert_equal(sub2, qe.expressions[1])
  end

  def test_quoted_tokens
    qe = ThinSearch::QueryExpression.for(%['foo' '"bar' "'baz"])
    assert_equal(qe.tokens[0], ThinSearch::QueryExpression::Token.new("'foo'"))
    assert_equal(qe.tokens[1], ThinSearch::QueryExpression::Token.new("'\"bar'"))
    assert_equal(qe.tokens[2], ThinSearch::QueryExpression::Token.new('"\'baz"'))
  end
end
