require 'rspec'
require 'rspec/retry'
require 'pry-debugger'

RSpec.configure do |config|
  config.verbose_retry = true
end
