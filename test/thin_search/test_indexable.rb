require 'test_helper'
require 'thin_search/indexable'
require 'thin_search/conversion'
require 'faker'
require 'securerandom'


class TestIndexable < ::ThinSearch::Test
  class TestIndexableModel
    include ::ThinSearch::Indexable
  end

  def test_indexable_is_in_ancestor_list
    assert(TestIndexableModel.ancestors.include?(::ThinSearch::Indexable))
  end

  def test_adds_indexable_class_method
    assert(TestIndexableModel.respond_to?(:indexable), "Does not respond to :indexable")
  end
end
