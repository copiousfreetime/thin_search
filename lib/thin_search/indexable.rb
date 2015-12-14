require 'thin_search/document'

module ThinSearch
  # Public: This is the manner in which an object is indexed.
  #
  # An object that wants to be indexed includs this module in its class
  module Indexable

    module ClassMethods
      def indexable( opts = {} )
        ThinSearch::Conversion.register(self, opts) # self registers
      end
    end

    def self.included( klass )
      return unless klass.instance_of?( Class )
      klass.extend(ClassMethods)
    end
  end
end
