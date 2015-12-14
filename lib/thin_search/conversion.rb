require 'thin_search/document'

module ThinSearch
  # Internal: A Conversion records how to convert instances of some other
  # Indexable class to and from Document instances
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
    # klass   - a Class or String representing the class to register
    # options - a Hash of options. These are passed directly to #new
    #
    # Returns the newly created Conversion instance
    def self.register(klass, options)
      registry[klass.to_s] = new(options)
    end

    # Internal: return the Conversion for the given class
    #
    # Returns the Conversion instance for the klass
    # Raises KeyError if the klass cannot be found
    def self.for(klass)
      registry.fetch(klass.to_s)
    end

    attr_reader :context
    attr_reader :finder_proc
    attr_reader :context_id_proc
    attr_reader :facets_proc
    attr_reader :important_proc
    attr_reader :normal_proc


    # Internal: Create and initialize a Conversion
    #
    # options - The Hash of options used to initialize a conversion
    #           :context   - a String that is a full class name (required)
    #           :finder    - a String that is the name of a method that is
    #                        called on the :context class to find an instance
    #                        or lambda that is called with the value of
    #                        Document#context_id (required)
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
    #
    def initialize(options = {})
      @context         = validate_argument(options, :context).to_s
      @finder_proc     = define_finder_proc(validate_argument(options, :finder))
      @context_id_proc = define_extract_proc(:context_id, validate_argument(options, :context_id))
      @facets_proc     = define_extract_proc(:facets,    options.fetch(:facets, nil))
      @important_proc  = define_extract_proc(:important, options.fetch(:important, nil))
      @normal_proc     = define_extract_proc(:normal,    options.fetch(:normal, nil))
    end

    def context_class
      @context_class ||= ::Module.const_get(@context)
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
      end
    end

    def extract_context_id(context_instance)
      context_id_proc.call(context_instance)
    end

    def extract_facets(context_instance)
      facets_proc.call(context_instance)
    end

    def extract_important(context_instance)
      important_proc.call(context_instance)
    end

    def extract_normal(context_instance)
      normal_proc.call(context_instance)
    end

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

    def define_finder_proc(finder)
      if finder.kind_of?(Proc) then
        a = finder.arity
        raise Error, ":finder proc has of #{a} instead of 1" unless a == 1
        return finder
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

    # Internal: create an Document from the given object
    #
    #
    #
    # Given an instance of the object this Conversion is 

  end
end
