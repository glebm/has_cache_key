HasCacheKey -- automatic cache key management For Rails
================================

Allows you describe cache keys in the models, and provides automatic expiration

Installation
------------

Add this line to your Gemfile:

    gem 'has_cache_key'

Usage
-----

Define cache_keys in your model

    class Listing < ActiveRecord::Base
      # Default cache key for the listing view
      has_cache_key :id
      # A cache key for the home page of category in location
      has_cache_key [:location_id, :category_id], name: :category_in_location_home_page
    end

To get a cache key in you can use one of the following:


   # Default cache key
   @listing.cache_key

   # A cache key
   @listing.cache_key(:category_in_location_home_page)

   # A cache key without a listing instance:
   Listing.cache_key(:category_in_location_home_page, category_id: 10, location_id: 10)


Your cache keys will be automatically updates after_save and after_destroy according to the attribute changes.


This project uses MIT-LICENSE.