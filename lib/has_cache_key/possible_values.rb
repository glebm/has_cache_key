module HasCacheKey
  class PossibleValues
    attr_reader :data
    include Enumerable

    # Yields with {slot_name => possible value} for all possible values
    # It yields exactly this many times:
    #  PRODUCT{i in 0..COUNT(slot))}
    #             COUNT(VALUES(slot)))
    def each(&block)
      return @results.each(&block) if @results
      @results = []
      cur_v_i = Array.new(@data.keys.length, 0)
      keys = @data.keys.sort_by(&:to_s)
      result = {}
      keys.each do |key|
        result[key] = @data[key][0]
      end
      while true
        r = result.dup
        @results << r
        block.call(r) if block
        keys.each_with_index do |k, k_i|
          v_i = ((cur_v_i[k_i] = (1 + cur_v_i[k_i]) % @data[k].length))
          result[k] = @data[k][v_i]
          if v_i > 0 # Found next ?
            break
          elsif k_i == keys.length - 1 # Last?
            return
          end
        end
      end
      @results
    end

    # Iterates over possible all possible values of keys
    # data hash of {slot_name => [possible values...]}
    def initialize(data)
      @data = data
    end
  end
end