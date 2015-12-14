require 'test_helper'
require 'test_model'
require 'thin_search/conversion'

class TestConversion < ::ThinSearch::Test

  attr_reader :options

  def setup
    super
    TestModel.populate(5)
    @options = {
      :context    => "TestModel",
      :context_id => :id,
      :finder     => :find_by_id,
      :facets     => :thinsearch_facets,
      :important  => :thinsearch_important,
      :normal     => :thinsearch_normal,
    }
  end

  def teardown
    super
    TestModel.clear
  end

  ## Context
  def test_raises_error_if_missing_context
    error = assert_raises(ThinSearch::Conversion::Error) {
      options.delete(:context)
      ThinSearch::Conversion.new(options)
    }
    assert_match(/context/, error.message)
  end

  def test_knows_context_class
     conversion = ThinSearch::Conversion.new(options)
     assert_equal(::TestModel, conversion.context_class)
  end

  ## Finder
  def test_raises_error_if_missing_finder
    error = assert_raises(ThinSearch::Conversion::Error) {
      options.delete(:finder)
      ThinSearch::Conversion.new(options)
    }
    assert_match(/finder/, error.message)
  end

  def test_finds_context_instance
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.first
     instance   = conversion.find_by_id(model.clone.id)
     assert_equal(model, instance)
  end

  def test_raises_error_if_invalid_proc_set_for_finder
    error = assert_raises(ThinSearch::Conversion::Error) {
      options[:finder] = lambda { |a, b| nil }
      ThinSearch::Conversion.new(options)
    }
    assert_match(/finder/, error.message)
  end

  ## Context Id
  def test_raises_error_if_missing_context_id
    error = assert_raises(ThinSearch::Conversion::Error) {
      options.delete(:context_id)
      ThinSearch::Conversion.new(options)
    }
    assert_match(/context_id/, error.message)
  end


  def test_extracts_context_id_as_symbol
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(model.id, conversion.extract_context_id(model))
  end

  def test_extracts_context_id_as_proc
     options[:context_id] = lambda { |i| i.email }
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(model.email, conversion.extract_context_id(model))
  end

  def test_raises_error_if_invalid_proc_set_for_context_id
    error = assert_raises(ThinSearch::Conversion::Error) {
      options[:context_id] = lambda { |a, b| nil }
      ThinSearch::Conversion.new(options)
    }
    assert_match(/context_id/, error.message)
  end

  ## Facets
  def test_extracts_facets
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(model.thinsearch_facets, conversion.extract_facets(model))
  end

  def test_extracts_facets_as_proc
     options[:facets] = lambda { |i| { "foo" => "bar" }}
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal({ "foo" => "bar"}, conversion.extract_facets(model))
  end

  def test_extracts_facets_as_nil
     options[:facets] = nil
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_nil(conversion.extract_facets(model))
  end

  def test_raises_error_if_invalid_proc_set_for_facets
    error = assert_raises(ThinSearch::Conversion::Error) {
      options[:facets] = lambda { nil }
      ThinSearch::Conversion.new(options)
    }
    assert_match(/facets/, error.message)
  end


  ## Important
  def test_extracts_important
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(model.thinsearch_important, conversion.extract_important(model))
  end

  def test_extracts_important_as_proc
     options[:important] = lambda { |i| %w[ foo bar baz ] }
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(%w[ foo bar baz ], conversion.extract_important(model))
  end

  def test_extracts_important_as_nil
     options.delete(:important)
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_nil(conversion.extract_important(model))
  end

  def test_raises_error_if_invalid_proc_set_for_important
    error = assert_raises(ThinSearch::Conversion::Error) {
      options[:important] = lambda { nil }
      ThinSearch::Conversion.new(options)
    }
    assert_match(/important/, error.message)
  end


  ## Normal
  def test_extracts_normal
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(model.thinsearch_normal, conversion.extract_normal(model))
  end

  def test_extracts_normal_as_proc
     options[:normal] = lambda { |i| %w[ wibble wobble ] }
     conversion = ThinSearch::Conversion.new(options)
     model      = TestModel.collection.values.last
     assert_equal(%w[ wibble wobble ], conversion.extract_normal(model))
  end

  def test_extracts_normal_as_nil
    options[:normal] = nil
    conversion = ThinSearch::Conversion.new(options)
    model      = TestModel.collection.values.last
    assert_nil(conversion.extract_normal(model))
  end

  def test_raises_error_if_invalid_proc_set_for_normal
    error = assert_raises(ThinSearch::Conversion::Error) {
      options[:normal] = lambda { nil }
      ThinSearch::Conversion.new(options)
    }
    assert_match(/normal/, error.message)
  end

  def test_converts_indexable_to_document
    conversion = ThinSearch::Conversion.new(options)
    model      = TestModel.collection.values.last
    document   = conversion.to_indexable_document(model)

    assert_equal(ThinSearch::Document, document.class)
    assert_equal("TestModel", document.context)
    assert_equal(model.id, document.context_id)
    assert_equal(model.thinsearch_facets, document.facets)
    assert_equal(model.thinsearch_important, document.important)
    assert_equal(model.thinsearch_normal, document.normal)
  end

  def test_converts_document_to_indexable
    conversion = ThinSearch::Conversion.new(options)
    TestModel.collection.each do |id, obj|
      dup  = obj.dup
      doc  = conversion.to_indexable_document(dup)
      obj2 = conversion.from_indexable_document(doc)
      assert_equal(obj, obj2)
    end
  end
end

