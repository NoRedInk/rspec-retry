require 'rspec/core'
require 'rspec/retry/version'
require 'rspec_ext/rspec_ext'

module RSpec
  class Retry
    def self.setup
      RSpec.configure do |config|
        config.add_setting :verbose_retry, :default => false
        config.add_setting :default_retry_count, :default => 1
        config.add_setting :default_sleep_interval, :default => 0
        config.add_setting :clear_lets_on_failure, :default => true
        config.add_setting :display_try_failure_messages, :default => false
        # If a list of exceptions is provided and 'retry' > 1, we only retry if
        # the exception that was raised by the example is in that list. Otherwise
        # we ignore the 'retry' value and fail immediately.
        #
        # If no list of exceptions is provided and 'retry' > 1, we always retry.
        config.add_setting :exceptions_to_retry, :default => []

        config.around(:each) do |ex|
          ex.run_with_retry
        end
      end
    end

    attr_reader :context, :ex

    def initialize(ex, opts = {})
      @ex = ex
      @ex.metadata.merge!(opts)
      current_example.attempts ||= 0
    end

    # context.example is deprecated, but RSpec.current_example is not
    # available until RSpec 3.0.
    def current_example
      RSpec.respond_to?(:current_example) ?
        RSpec.current_example : @ex.example
    end

    def retry_count
      [
          (
          ENV['RSPEC_RETRY_RETRY_COUNT'] ||
              ex.metadata[:retry] ||
              RSpec.configuration.default_retry_count
          ).to_i,
          1
      ].max
    end

    def attempts
      current_example.attempts ||= 0
    end

    def attempts=(val)
      current_example.attempts = val
    end

    def clear_lets
      !ex.metadata[:clear_lets_on_failure].nil? ?
          ex.metadata[:clear_lets_on_failure] :
          RSpec.configuration.clear_lets_on_failure
    end

    def sleep_interval
      ex.metadata[:retry_wait] ||
          RSpec.configuration.default_sleep_interval
    end

    def exceptions_to_retry
      ex.metadata[:exceptions_to_retry] ||
          RSpec.configuration.exceptions_to_retry
    end

    def verbose_retry?
      RSpec.configuration.verbose_retry?
    end

    def display_try_failure_messages?
      RSpec.configuration.display_try_failure_messages?
    end

    def run
      example = current_example

      loop do
        if verbose_retry?
          if attempts > 0
            message = "RSpec::Retry: #{ordinalize(attempts + 1)} try #{example.location}"
            message = "\n" + message if attempts == 1
            RSpec.configuration.reporter.message(message)
          end
        end

        example.clear_exception
        ex.run

        self.attempts += 1

        break if example.exception.nil?

        break if attempts >= retry_count

        if exceptions_to_retry.any?
          break unless exceptions_to_retry.any? do |exception_klass|
            example.exception.is_a?(exception_klass)
          end
        end

        if verbose_retry? && display_try_failure_messages?
          if attempts != (retry_count-1)
            try_message = "#{ordinalize(attempts + 1)} Try error in #{example.location}:\n #{example.exception.to_s} \n"
            RSpec.configuration.reporter.message(try_message)
          end
        end

        example.example_group_instance.clear_lets if clear_lets

        sleep sleep_interval if sleep_interval.to_i > 0
      end
    end

    private

    # borrowed from ActiveSupport::Inflector
    def ordinalize(number)
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

RSpec::Retry.setup
