require 'faker'
require 'securerandom'

class TestModel

  def self.collection
    @collection ||= Hash.new
  end

  def self.clear
    @collection.clear
  end

  def self.find_by_id(id)
    collection.fetch(id)
  end

  def self.batch_find_by_ids(ids)
    ids.map { |id| find_by_id(id) }
  end

  def self.register(key, value)
    collection[key] = value
  end

  def self.populate(count)
    count.times do
      o = new
      register(o.id, o)
    end
  end

  def self.generate_collection(count)
    Hash.new.tap do |h|
      count.times do
        o = new
        h[o.id] = o
      end
      collection.merge!(h)
    end
  end

  attr_reader   :id
  attr_accessor :date
  attr_accessor :color
  attr_accessor :department
  attr_accessor :email
  attr_accessor :name
  attr_accessor :words
  attr_accessor :creature

  def initialize
    @id         = SecureRandom.uuid
    @date       = ::Faker::Date.backward(365)
    @color      = ::Faker::Commerce.color
    @department = ::Faker::Commerce.department
    @email      = ::Faker::Internet.free_email
    @name       = ::Faker::Name.name
    @words      = ::Faker::Hipster.paragraph
    @creature   = ::Faker::Team.creature
  end

  def thinsearch_facets
    { :date => date, :color => color, :department => department }
  end

  def thinsearch_important
    [ email, name ]
  end

  def thinsearch_normal
    words
  end

  def thinsearch_exact
    creature
  end

  def _thin_search_index_unique_id
    [ self.class.name, id ].join(".")
  end
end
