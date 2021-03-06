require 'map'
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
        opts = Map.new(opts)
        opts = _thin_search_default_options.merge(opts)
        conversion = ThinSearch::Conversion.register(opts) # self registers
        Indexable::Registry[conversion.context_class] = opts.fetch(:index) { ::ThinSearch::Global.index }
      end

      def _thin_search_default_options
        Map.new.tap do |h|
          h[:context]    = self
          h[:context_id] = :id

          if ::ThinSearch::Indexable.is_mongoid?(self) then
            h[:finder] = lambda { |context_id| self.where(:id => context_id).first }
            h[:batch_finder] = lambda { |context_ids| self.where(:id.in => context_ids) }
          elsif ::ThinSearch::Indexable.is_active_record?(self) then
            h[:finder] = lambda { |context_id| self.where(primary_key => context_id).limit(1).first }
            h[:batch_finder] = lambda { |context_ids| self.where(primary_key => context_ids) }
          end
        end
      end
    end

    def self.included( klass )
      return unless klass.instance_of?( Class )
      klass.extend(ClassMethods)
      inject_lifecycle_hooks(klass)
    end

    # Internal: inject AR / Mongoid save/delete hooks
    #
    # Luckily at the moment its the same duck typing to hook into Mongoid or
    # AcitveRecord hooks. So we just look for either of them and go from there.
    #
    def self.inject_lifecycle_hooks(klass)
      if is_active_record?(klass) || is_mongoid?(klass) then

        klass.after_create do
          begin
            _thin_search_add
          rescue Object
            nil
          end
        end

        klass.after_update do
          begin
            _thin_search_update
          rescue Object
            nil
          end
        end

        klass.after_destroy do
          begin
            _thin_search_destroy
          rescue Object
            nil
          end
        end
      end
    end

    # Internal: is hte given class an ActiveRecord object
    #
    def self.is_active_record?(klass)
      defined?(::ActiveRecord::Base) && (klass < ::ActiveRecord::Base)
    end

    # Internal: is the given clasa a Mongoid::Document
    #
    def self.is_mongoid?(klass)
      defined?(::Mongoid::Document) && (klass < ::Mongoid::Document)
    end

    # Internal: return the conversion for this object
    #
    def _thin_search_conversion
      ::ThinSearch::Conversion.for(self)
    end

    # Internal: Find the Index for this document
    #
    def _thin_search_index
      Registry.fetch(_thin_search_conversion.context_class)
    end

    # Internal: return the index unique for this model
    #
    def _thin_search_index_unique_id
      _thin_search_conversion.extract_index_unique_id(self)
    end

    # Internal: add this document to its index.
    #
    def _thin_search_add
      _thin_search_index.add(self)
    end

    # Internal: update this document in its index
    #
    def _thin_search_update
      _thin_search_index.update(self)
    end

    # Internal: delete this document from its index
    #
    def _thin_search_destroy
      _thin_search_index.remove(self)
    end
  end
end
