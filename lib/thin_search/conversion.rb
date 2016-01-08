require 'map'
require 'thin_search/error'
require 'thin_search/document'

module ThinSearch
  # Internal: A Conversion records how to convert instances of some other
  # Indexable class to and from Document instances
  #
  # A Conversion describes how to convert some other object into a Document
  # instance. This is done through a set of options. All of the options except
  # for :context may take a String, Symbol or Proc. If a String or Symbol is
  # given then that represents a method name to invoke. If a Proc is given, that
  # that is invoked directly.
  #
  # The :context and :finder options are used when converting a Document to an
  # instance of the class in :context.
  #
  # :context - This is a String or a Class that is the fully qualified class
  #            name of the objects that willb e converted to/from Document 
  #            instances by this Conversion.
  #
  # :finder  - This is method to invoke on :context. The method will be passed a
  #            single String parameter that is the **id** of the instance to
  #            find. This is the value from Document#context_id. If :finder is a
  #            Proc then it will be passed that parameter, and the Proc is
  #            expected to return the appropriate instance.
  #
  # :batch_finder  - This is method to invoke on :context. The method will be 
  #                  passed a an array of String parameters that are the **ids**
  #                  of the instances to find. These are the values from 
  #                  Document#context_id. If :batch_finder is a Proc then it will
  #                  be passed the array as a parameter, and the Proc is expected 
  #                  to return the appropriate instances.
  #
  # The :context_id, :facets, :imporant, and :normal options are used when
  # converting an Indexable item to a Document. If these are a String or Symbol,
  # then those are public methods that will be directly invoked on the Indexable
  # item passed to Conversion.
  #
  # If these are Proc's then the Proc will be passed the instance that is being
  # converted and the Proc is epxected to return the appropriate value.
  #
  # :context_id - String/Symbol/Proc that returns the uniquely identifing String
  #               value of this instance in the context of :context
  # :facets     - String/Symbol/Proc that returns a Hash of low-cardinality
  #               items associated with the Indexable item.
  # :important  - String/Symbol/Proc that returns a String or an Array of
  #               Strings of high-important things in the Indexable item. When
  #               searching the Index items that match this will be returned
  #               before items that match :normal
  # :normal     - String/Symbol/Proc that returns a String or an Array of
  #               Strings of text that is to be indexed.
  # :exact      - String/Symbol/Proc that returns a String or an Array of
  #               Strings that are to be exact matched
  #
  class Conversion
    class Error < ::ThinSearch::Error ; end

    # The global Registry for storing Conversion instances. It is set here so it is
    # allocated at parse time.
    @registry = Hash.new

    # Internal: Get the global Conversion Registry instance
    #
    # Returns the global Conversion Registry
    def self.registry
      @registry
    end

    # Internal: register a Conversion with the registry
    #
    # options_or_conversion - a Hash of options to pas to #new or an instance of 
    #                         Conversion
    #
    # Returns the newly registered Conversion instance
    def self.register(options_or_conversion)
      conversion = nil
      case options_or_conversion
      when Hash
        conversion = new(options_or_conversion)
      when Conversion
        conversion = options_or_conversion
      else
        raise Error, "It is only valid to register a Hash or a Conversion, you attempted to register #{options_or_conversion.class}"
      end
      registry[conversion.context] = conversion
    end

    # Internal: return the Conversion for the given object
    #
    # This can take a String, a Class or an instance of something. It will
    # attempt to figure out the right key to lookup in the registry
    #
    # Returns the Conversion instance for the klass
    # Raises Conversion::Error if the klass cannot be found
    def self.for(item)
      registry.fetch(registry_key_for(item))
    rescue KeyError
      raise Error, "Unable to find conversion for #{item} in registry"
    end

    # Internal: convert the given indexable item to a Document.
    #
    # Assuming the given item's class is registered, then convert it to a
    # Document
    #
    # Returns a Document
    # raises Conversion::Error if it is unable to convert
    #
    def self.to_indexable_document(item)
      conversion = item.kind_of?(Class) ? Conversion.for(item) : Conversion.for(item.class)
      conversion.to_indexable_document(item)
    end

    # Internal: convert the given Document to its original class instance
    #
    # Assuming the given item's class is registered, then convert the document
    # to its original class instance
    #
    # Returns an instannce
    # raises Conversion::Error if it is unable to convert
    #
    def self.from_indexable_document(document)
      conversion = Conversion.for(document.context)
      conversion.from_indexable_document(document)
    end

    # Internal: Covnert the given Object into something that is valid as a
    # registry key.
    #
    # Returns String
    #
    def self.registry_key_for(item)
      case item
      when String
        item
      when Class
        item.to_s
      else
        item.class.to_s
      end
    end

    attr_reader :context
    attr_reader :finder_proc
    attr_reader :batch_finder_proc
    attr_reader :context_id_proc
    attr_reader :facets_proc
    attr_reader :important_proc
    attr_reader :normal_proc
    attr_reader :exact_proc


    # Internal: Create and initialize a Conversion
    #
    # options - The Hash of options used to initialize a conversion
    #           :context   - a String that is a full class name (required)
    #           :finder    - a String that is the name of a method that is
    #                        called on the :context class to find an instance
    #                        or lambda that is called with the value of
    #                        Document#context_id (required)
    #           :batch_finder - Array of String same concept as :finder but for
    #                           arrays of context items
    #           :context_id- a String/Symbol that is the name of a method to call
    #                        on an instance of :context to retrieve its id. Or a
    #                        lambda that when given an instance of :context it
    #                        will return the id (required)
    #           :facets    - a String/Symbol that is the name of a method to call
    #                        on an instance of :context to retrieve a Hash. Or a
    #                        lambda that when given an instance of :context it
    #                        will return the facets hash
    #           :important - a String/Symbol that is the name of a method to call
    #                        on an instance of :context to retrieve the
    #                        "important" terms to index. Or a lambda that when 
    #                        given an instance of :context it will return the same data.
    #           :normal    - a String/Symbol that is the name of a method to call
    #                        on an instance of :context to retrieve the
    #                        "normal" terms to index. Or a lambda that when given
    #                        an instance of :context it will return the same data
    #           :exact     - a String/Symbol that is the name of a method to
    #                        call on an instance of :context to retrieve the
    #                        "exact" terms to index. Or a lambda that when given
    #                        an instance of :context will return the same data
    #
    def initialize(options = {})
      options          = Map.new(options)
      @context         = validate_argument(options, :context).to_s
      @finder_proc     = define_finder_proc(validate_argument(options, :finder), "finder")
      @batch_finder_proc = define_finder_proc(validate_argument(options, :batch_finder), "batch_finder")
      @context_id_proc = define_extract_proc(:context_id, validate_argument(options, :context_id))
      @facets_proc     = define_extract_proc(:facets,    options.fetch(:facets, nil))
      @important_proc  = define_extract_proc(:important, options.fetch(:important, nil))
      @normal_proc     = define_extract_proc(:normal,    options.fetch(:normal, nil))
      @exact_proc      = define_extract_proc(:exact,     options.fetch(:exact, nil))
    end

    def context_class
      @context_class ||= constantize(@context)
    end

    def to_indexable_document(context_instance)
      if !context_instance.is_a?(context_class) then
        raise Error, "Invalid instance, Attempting to conver #{context_instance.class} to Document and this Conversion converts #{@context}"
      end

      ::ThinSearch::Document.new do |doc|
        doc.context    = context
        doc.context_id = extract_context_id(context_instance)
        doc.facets     = extract_facets(context_instance)
        doc.important  = extract_important(context_instance)
        doc.normal     = extract_normal(context_instance)
        doc.exact      = extract_exact(context_instance)
      end
    end

    # Internal: Find an instance of context_class by context_id
    #
    # Returns an instance of context_class
    def find_by_id(context_id)
      finder_proc.call(context_id)
    end

    # Internal: Find a batch of instances from the list of context_ids
    #
    # Returns an Array of context_class instances
    def batch_find_by_ids(context_ids)
      batch_finder_proc.call(context_ids)
    end

    # Internal: return the context_id form an instance of context_class
    #
    # Returns the context_id
    def extract_context_id(context_instance)
      context_id_proc.call(context_instance)
    end

    # Internal: return the unique index id from an instance of context_class
    #
    # This value should be unique within the entire index this document is
    # stored.
    #
    # Returns a String
    def extract_index_unique_id(context_instance)
      [context, extract_context_id(context_instance)].join(".")
    end

    # Internal: returns the facets hash from the instance of context_class
    #
    # Returns a Hash
    def extract_facets(context_instance)
      facets_proc.call(context_instance)
    end

    # Internal: returns the imortant data to index
    #
    # Returns an Array of Strings
    def extract_important(context_instance)
      important_proc.call(context_instance)
    end

    # Internal: returns the normal data to index
    #
    # Returns an Array of Strings
    def extract_normal(context_instance)
      normal_proc.call(context_instance)
    end

    # Internal: returns the exact data to index
    #
    # Returns an Array of Strings
    def extract_exact(context_instance)
      exact_proc.call(context_instance)
    end

    # Internal: Finds the instance of context_class that matches the Document
    #
    # Returns an instance of context_class
    # Raises Error
    def from_indexable_document(document)
      raise Error, "Unable to convert #{document.context} to #{context}" unless document.context == context
      find_by_id(document.context_id)
    end

    private

    def validate_argument(options, argument)
      options.fetch(argument)
    rescue KeyError
      raise Error, "Missing conversion argument `#{argument}`"
    end

    def define_finder_proc(finder, proc_name)
      if finder.kind_of?(Proc) then
        a = finder.arity
        raise Error, "Invalid proc for :#{proc_name}, given proc takes #{a} arguments, should accept only 1" unless a == 1
        finder
      else
        lambda { |context_id|
          context_class.public_send(finder, context_id)
        }
      end
    end

    def define_extract_proc(name, proc_or_method_name)
      case proc_or_method_name
      when Proc
        a = proc_or_method_name.arity
        raise Error, "Invalid proc for :#{name}, given proc takes #{a} arguments, should accept only 1" unless a == 1
        proc_or_method_name
      when nil
        lambda { |context_instance|
          nil
        }
      else
        lambda { |context_instance|
          context_instance.public_send(proc_or_method_name)
        }
      end
    end

    # Thanks yehuda
    def constantize(context)
      names    = context.split('::')
      constant = Object
      so_far   = []
      names.each do |name|
        so_far << name
        if constant.const_defined?(name, false) then
          constant = constant.const_get(name)
        else
          raise NameError, "Unable to find constant #{so_far.join("::")}"
        end
      end
      return constant
    end
  end
end
