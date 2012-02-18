require File.expand_path("../lib/has_cache_key/version", __FILE__)


Gem::Specification.new do |s|
  s.name = "has_cache_key"
  s.author = 'Gleb Mazovetskiy'
  s.email = 'glex.spb@gmail.com'
  s.summary = "Automatic Cache Key Management for Rails Models. v#{HasCacheKey::VERSION}"
  s.homepage = "https://github.com/glebm/has_cache_key"
  s.description = "Allows you to define multiple cache keys on the module, and automatically expires them."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.md"]
  s.add_dependency "rails", "~> 3.2"
  s.version = HasCacheKey::VERSION
end