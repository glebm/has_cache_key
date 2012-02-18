require 'spec_helper'
require 'has_cache_key/cache_key'

describe HasCacheKey::CacheKey do
  it 'formats values' do
    key = HasCacheKey::CacheKey.new(:location_id, :language_id, format: 'listing_view-%{location_id}-%{language_id}')
    key.format.should == 'listing_view-%{location_id}-%{language_id}'
    key.format("location_id" => 10, :language_id => 11).should == 'listing_view-10-11'
  end

  it 'accepts a block' do
    key = HasCacheKey::CacheKey.new(:location_id, :language_id, format: lambda { |v| "TEST-#{10 * v[:location_id]}-#{v[:language_id]}" })
    key.format(location_id: 9, language_id: 12).should == 'TEST-90-12'
  end

  it 'accepts a name converting it to Symbol' do
    key = HasCacheKey::CacheKey.new(:location_id, name: 'main_key')
    key.name.should == :main_key
  end
end

