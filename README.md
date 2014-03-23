# RSpec::Retry

RSpec::Retry adds ``:retry`` option to rspec example.
It is for randomly failing example.
If example has ``:retry``, rspec retry specified times until success.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-retry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-retry

require in ``spec_helper.rb``

```ruby
# spec/spec_helper.rb
require 'rspec/retry'

RSpec.configure do |config|
  config.verbose_retry = true # show retry status in spec process
end
```

## Usage

```ruby
it 'should randomly success', :retry => 3 do
  rand(2).should == 1
end

it 'should succeed after a while', :retry => 3, :retry_wait=>10 do
  command('service myservice status').should == 'started'
end
# run spec (following log is shown if verbose_retry options is true)
# RSpec::Retry: 2nd try ./spec/lib/random_spec.rb:49
# RSpec::Retry: 3rd try ./spec/lib/random_spec.rb:49
```

## Configuration

- __:verbose_retry__(default: *false*) Print retry status
- __:default_retry_count__(default: *1*) If retry count is not set in example, this value is used by default
- __:retry_wait__(default: *0*) Seconds to wait between retries
- __:clear_lets_on_failure__(default: *true*) Clear memoized value for ``let`` before retrying

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
