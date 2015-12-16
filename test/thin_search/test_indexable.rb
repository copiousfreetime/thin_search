require 'test_helper'
require 'thin_search/indexable'
require 'thin_search/conversion'
require 'faker'
require 'securerandom'


class TestIndexable < ::ThinSearch::Test
  class TestIndexableModel
    include ::ThinSearch::Indexable
    indexable :context_id => lambda { |i| i.id },
      :finder       => lambda { |id| TestIndexableModel.find_by(:id => id) },
      :batch_finder => lambda { |ids| TestIndexableModel.batch_find_by_ids(ids) },
      :facets       => lambda { |i| { :date => i.date, :department => i.department, :color => i.color } },
      :important    => lambda { |i| [ i.email, i.name ] },
      :normal       => :bio
  end

  def test_indexable_is_in_ancestor_list
    assert(TestIndexableModel.ancestors.include?(::ThinSearch::Indexable))
  end

  def test_adds_indexable_class_method
    assert(TestIndexableModel.respond_to?(:indexable), "Does not respond to :indexable")
  end

  def test_is_registered
    assert(::ThinSearch::Indexable::Registry.has_key?(::TestIndexable::TestIndexableModel))
  end
end
