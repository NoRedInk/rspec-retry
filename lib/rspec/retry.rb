require 'rspec/core'
require 'rspec/retry/version'
require 'rspec_ext/rspec_ext'

module RSpec
  class Retry
    def self.apply
      RSpec.configure do |config|
        config.add_setting :verbose_retry, :default => false
        config.add_setting :default_retry_count, :default => 1
        config.add_setting :default_sleep_interval, :default => 0
        config.add_setting :clear_lets_on_failure, :default => true
        # If a list of exceptions is provided and 'retry' > 1, we only retry if
        # the exception that was raised by the example is in that list. Otherwise
        # we ignore the 'retry' value and fail immediately.
        #
        # If no list of exceptions is provided and 'retry' > 1, we always retry.
        config.add_setting :exceptions_to_retry, :default => []
        config.add_setting :exceptions_to_fail_hard, :default => []

        # context.example is deprecated, but RSpec.current_example is not
        # available until RSpec 3.0.
        fetch_current_example = RSpec.respond_to?(:current_example) ?
          proc { RSpec.current_example } : proc { |context| context.example }

        config.around(:each) do |ex|
          example = fetch_current_example.call(self)
          retry_count = ex.metadata[:retry] || RSpec.configuration.default_retry_count
          sleep_interval = ex.metadata[:retry_wait] || RSpec.configuration.default_sleep_interval
          exceptions_to_retry = ex.metadata[:exceptions_to_retry] || RSpec.configuration.exceptions_to_retry
          exceptions_to_fail_hard = ex.metadata[:exceptions_to_fail_hard] || RSpec.configuration.exceptions_to_fail_hard

          clear_lets = ex.metadata[:clear_lets_on_failure]
          clear_lets = RSpec.configuration.clear_lets_on_failure if clear_lets.nil?

          retry_count.times do |i|
            if RSpec.configuration.verbose_retry?
              if i > 0
                message = "RSpec::Retry: #{RSpec::Retry.ordinalize(i + 1)} try #{example.location}"
                message = "\n" + message if i == 1
                RSpec.configuration.reporter.message(message)
              end
            end
            example.clear_exception
            ex.run

            break if example.exception.nil?

            if exceptions_to_retry.any?
              break unless exceptions_to_retry.include?(example.exception.class)
            end

            if exceptions_to_fail_hard.any?
              break if exceptions_to_fail_hard.include?(example.exception.class)
            end

            self.clear_lets if clear_lets
            sleep sleep_interval if sleep_interval.to_i > 0
          end
        end
      end
    end

    # borrowed from ActiveSupport::Inflector
    def self.ordinalize(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}th"
      else
        case number.to_i % 10
        when 1; "#{number}st"
        when 2; "#{number}nd"
        when 3; "#{number}rd"
        else    "#{number}th"
        end
      end
    end
  end
end

RSpec::Retry.apply
