source 'https://rubygems.org'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2')
  gem "pry-debugger"
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2')
  gem "byebug", "< 9.1"
  gem "pry-byebug"
else
  gem "pry-byebug"
end

# Specify your gem's dependencies in rspec-retry.gemspec
gemspec
