require 'rspec'
require 'rspec/retry'
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2')
  require "pry-debugger"
else
  require "pry-byebug"
end

RSpec.configure do |config|
  config.verbose_retry = true
end
