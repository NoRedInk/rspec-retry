# RSpec::Retry

RSpec::Retry adds a ``:retry`` option for intermittently failing rspec examples.
If an example has the ``:retry`` option, rspec will retry the example the
specified number of times until the example succeeds.

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
it 'should randomly succeed', :retry => 3 do
  expect(rand(2)).to eq(1)
end

it 'should succeed after a while', :retry => 3, :retry_wait => 10 do
  expect(command('service myservice status')).to eq('started')
end
# run spec (following log is shown if verbose_retry options is true)
# RSpec::Retry: 2nd try ./spec/lib/random_spec.rb:49
# RSpec::Retry: 3rd try ./spec/lib/random_spec.rb:49
```

## Configuration

- __:verbose_retry__(default: *false*) Print retry status
- __:default_retry_count__(default: *1*) If retry count is not set in an example, this value is used by default
- __:default_sleep_interval__(default: *0*) Seconds to wait between retries
- __:clear_lets_on_failure__(default: *true*) Clear memoized values for ``let``s before retrying
- __:exceptions_to_retry__(default: *[]*) List of exceptions that will trigger a retry (when empty, all exceptions will)

## Environment Variables
- __RSPEC_RETRY_RETRY_COUNT__ can override the retry counts even if a retry count is set in an example or default_retry_count is set in a configuration.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a pull request
