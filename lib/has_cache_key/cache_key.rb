module HasCacheKey
  class CacheKey
    attr_reader :name, :keys

    # *keys, options
    def initialize(*args)
      options = args.extract_options!
      keys = args
      @keys = args.map { |k| k.is_a?(Symbol) ? k : k.to_sym }.freeze
      @format = options[:format]
      if options[:name]
        @name = options[:name]
        @name = @name.to_sym unless @name.is_a?(Symbol)
      end
    end

    def format(values = nil)
      return @format if !values
      values = values.symbolize_keys
      fmt = @format
      fmt.is_a?(Proc) ? fmt.call(values) : (fmt % values)
    end
  end
end