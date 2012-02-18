require 'spec_helper'
require 'active_record'
require 'action_controller'
require 'has_cache_key'


describe HasCacheKey::ModelExt do
  before(:all) do
    ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: ':memory:'
    )

    ActiveRecord::Schema.define do
      create_table :listings do |t|
        t.integer :location_id
        t.integer :language_id
        t.timestamps
      end
    end

    class Listing < ActiveRecord::Base
      has_cache_key :id, format: lambda { |v| "l-#{v[:id]}" }
      has_cache_key :location_id, name: :listings_in_location_home
      has_cache_key :location_id, :language_id, name: :complex_key
    end
  end


  describe '::cache_keys' do
    it 'lists all the cache_keys' do
      Listing.cache_keys.map(&:name).should == [:listing, :listings_in_location_home, :complex_key]
    end
  end

  describe '::cache_key(name)' do
    it 'returns the string for a cache key with a given name name and attribute values' do
      Listing.cache_key(:listing, id: 5).should == 'l-5'
      Listing.cache_key('listing', id: 5).should == 'l-5'
      Listing.cache_key('listing', 'id' => 5).should == 'l-5'
    end
  end

  describe '#cache_key(name)' do
    it 'uses model based name as the default' do
      listing = Listing.create
      listing.cache_key.should == "l-#{listing.id}"
    end

    it 'returns the actual string for the given cache key and object' do
      Listing.new(location_id: 41).cache_key(:listings_in_location_home).should == "listings_in_location_home-41"
    end
  end

  it 'updates cache keys after save' do
    listing = Listing.new(location_id: 41)
    original_method = listing.method(:expire_cache_keys)
    listing.should_receive(:expire_cache_keys).exactly(3).times do |*args|
      original_method.call(*args)
    end
    listing.save
    listing.save
    listing.save
  end

  it 'expires caches' do
    listing = Listing.create(location_id: 41, language_id: 10)
    original_method = listing.method(:expire_cache_keys)
    listing.should_receive(:expire_cache_keys).exactly(1).times do |*args|
      original_method.call(*args)
    end

    listing.should_receive(:expire_fragment_key).exactly(7).times do |*args|
      puts "--  Expiring #{args.join(', ')}"
    end

    listing.update_attributes location_id: 42, language_id: 20
  end

  after :all do
    ActiveRecord::Base.connection.close
    Object.__send__ :remove_const, :Listing
  end
end