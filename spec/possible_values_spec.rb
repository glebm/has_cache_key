require 'spec_helper'
require 'has_cache_key/possible_values'

describe HasCacheKey::PossibleValues do
  it 'iterates over all values' do
    pv = HasCacheKey::PossibleValues.new(
        slot_1: %w( A B C ),
        slot_2: (1..3).to_a,
        slot_3: %w( xxx )
    )

    r = []
    pv.each { |v| r << v }

    all_combinations = [
        {slot_1: 'A', slot_2: 1, slot_3: 'xxx'},
        {slot_1: 'A', slot_2: 2, slot_3: 'xxx'},
        {slot_1: 'A', slot_2: 3, slot_3: 'xxx'},
        {slot_1: 'B', slot_2: 1, slot_3: 'xxx'},
        {slot_1: 'B', slot_2: 2, slot_3: 'xxx'},
        {slot_1: 'B', slot_2: 3, slot_3: 'xxx'},
        {slot_1: 'C', slot_2: 1, slot_3: 'xxx'},
        {slot_1: 'C', slot_2: 2, slot_3: 'xxx'},
        {slot_1: 'C', slot_2: 3, slot_3: 'xxx'}
    ]


    r.should have(all_combinations.length).elements
    all_combinations.each do |v|
      r.should include(v)
    end
  end
end