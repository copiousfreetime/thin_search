require 'test_helper'
require 'thin_search/indexable'
require 'thin_search/conversion'
require 'faker'
require 'securerandom'

class TestIndexableModel
  include ::ThinSearch::Indexable

  # indexable :context_id => lambda { |i| i.id },
  #           :facets     => lambda { |i| { :date => i.date, :department => i.department, :color => i.color } },
  #           :important  => lambda { |i| [ i.email, i.name ] },
  #           :normal     => :words

  attr_reader :id
  attr_accessor :date
  attr_accessor :color
  attr_accessor :department
  attr_accessor :email
  attr_accessor :name
  attr_accessor :words

  def initialize
    @id         = SecureRandom.uuid
    @date       = ::Faker::Date.backward(365)
    @color      = ::Faker::Commerce.color
    @department = ::Faker::Commerce.department
    @email      = ::Faker::Internet.free_email
    @name       = ::Faker::Name.name
    @words      = ::Faker::Hipster.paragraph
  end
end


class TestDocument < ::ThinSearch::Test

  def test_indexable_is_in_ancestor_list
    assert(TestIndexableModel.ancestors.include?(::ThinSearch::Indexable))
  end

  def test_adds_indexable_class_method
    assert(TestIndexableModel.respond_to?(:indexable), "Does not respond to :indexable")
  end
end
