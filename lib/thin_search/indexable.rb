require 'thin_search/document'

module ThinSearch
  # Public: This is the manner in which an object is indexed.
  #
  # An object that wants to be indexed includs this module in its class and then
  # invokes the class methdo :indexable
  #
  # Example:
  #
  #   class IndexableModel
  #     include ::ThinSearch::Indexable
  #
  #     indexable :context_id => lambda { |i| i.id },
  #               :finder     => lambda { |id| ::IndexableModel.find_by(:id => id) },
  #               :facets     => lambda { |i| { :date => i.date, :department => i.department, :color => i.color } },
  #               :important  => lambda { |i| [ i.email, i.name ] },
  #               :normal     => :bio
  #   end
  #
  module Indexable

    module ClassMethods
      def indexable( opts = {} )
        unless opts.has_key?(:context) || opts.has_key?('context') then
          opts[:context] = self
        end
        ThinSearch::Conversion.register(opts) # self registers
      end
    end

    def self.included( klass )
      return unless klass.instance_of?( Class )
      klass.extend(ClassMethods)
    end
  end
end
