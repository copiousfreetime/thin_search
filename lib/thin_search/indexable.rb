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
  #               :normal     => :bio,
  #               :index      => ::ThinSearch::Global.index
  #   end
  #
  module Indexable
    # The global Registry for storing the map of indexable items to their
    # appropriate index.
    Registry = Hash.new

    module ClassMethods
      def indexable( opts = {} )
        unless opts.has_key?(:context) || opts.has_key?('context') then
          opts[:context] = self
        end
        conversion = ThinSearch::Conversion.register(opts) # self registers
        Indexable::Registry[conversion.context_class] = opts.fetch(:index) { ::ThinSearch::Global.index }
      end
    end

    def self.included( klass )
      return unless klass.instance_of?( Class )
      klass.extend(ClassMethods)
    end

    def _thin_search_index
      conversion = ::ThinSearch::Conversion.for(self)
      Registry.fetch(conversion.context_class)
    end
  end
end
