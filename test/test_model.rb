require 'faker'
require 'securerandom'

class TestModel
  @collection = Hash.new

  def self.collection
    @collection
  end

  def self.clear
    @collection.clear
  end

  def self.find_by_id(id)
    collection.fetch(id)
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
    end
  end

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

  def thinsearch_facets
    { :date => date, :color => color, :department => department }
  end

  def thinsearch_important
    [ email, name ]
  end

  def thinsearch_normal
    words
  end
end
