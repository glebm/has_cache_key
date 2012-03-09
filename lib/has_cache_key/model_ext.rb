require 'has_cache_key/possible_values'
require 'has_cache_key/cache_key'

module HasCacheKey
  module ModelExt
    def self.included(base)
      base.extend ClassMethods
      base.after_save :expire_cache_keys
      base.after_destroy :expire_cache_keys
    end

    def expire_cache_keys(*args)
      # First, assemble all keys the listing is involved in, and the values that were affected
      affected_values_by_key = {}
      attr_changes = self.changes
      keys = self.class.cache_keys.map(&:keys)
      keys.flatten!
      keys.uniq!

      keys.each do |key|
        affected_values_by_key[key] = if attr_changes.has_key?(key)
                                        # For :updated_at only expire the first value , because the second one never exists
                                        if key == :updated_at
                                          [attr_changes[key][0]]
                                        else
                                          attr_changes[key]
                                        end
                                      else
                                        [send(key)]
                                      end
      end

      self.class.cache_keys.each do |cache_key|
        PossibleValues.new(affected_values_by_key.slice(*cache_key.keys)).each do |interpolations|
          expire_fragment_key(cache_key.format(interpolations))
        end
      end
    end

    # @returns cache key string for the cache key with the given name
    def cache_key(name = self.class.name.to_s.demodulize.underscore)
      self.class.cache_key(name, attributes)
    end

    protected
    def expire_fragment_key(key)
      (@controller ||= ActionController::Base.new).expire_fragment(key)
    end

    module ClassMethods
      def cache_keys
        @cache_keys ||= []
      end

      def cache_key(name, format_values = nil)
        (@cache_key_by_name ||= {}.with_indifferent_access)[name].format(format_values)
      end


      # Adds a cache key association to your model
      # @param [Array|Symbol] composed_of keys that make up the cache key,
      #   can be also passed as @option composed_of
      #
      # @option [Symbol] name unique name which is used to refer to the cache key from your application
      #   defaults to: name.to_s.demodulize.underscore
      #
      # @example Expire on any update:
      #   has_cache_key :product_snippet, composed_of: [:updated_at]
      def has_cache_key(*args)
        if (options = args.extract_options!)
          options[:composed_of] ||= args.flatten
        else
          options = {}
        end
        options[:composed_of] = Array(options[:composed_of])
        options[:name] ||= name.to_s.demodulize.underscore
        options[:format] ||= "#{options[:name]}-#{options[:composed_of].map { |k| "%{#{k}}" }.join('-')}"
        cache_key = HasCacheKey::CacheKey.new(*options[:composed_of], options)
        (@cache_keys ||= []) << cache_key
        (@cache_key_by_name ||= {}.with_indifferent_access)[cache_key.name] = cache_key
      end
    end
  end
end

require 'active_record'
ActiveRecord::Base.class_eval { include HasCacheKey::ModelExt }
