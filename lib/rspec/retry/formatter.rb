require "rspec/core/formatters/base_text_formatter"

class RSpec::Retry::Formatter < RSpec::Core::Formatters::BaseTextFormatter
  def initialize(output)
    super(output)
    @tries = {}
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    output << "\nRSpec Retry Summary:\n"
    @tries.each do |key, retry_data|
      next unless retry_data[:tries] > 1
      output << "\t" << key << ": " << retry_data[:successes].to_s << ' out of ' << retry_data[:tries] << " attempts passed.\n"
    end
    output << @tries.count << ' of ' <<  example_count << " tests were retried.\n"
    output <<  failure_count << " tests failed all retries.\n"
  end

  def example_started(example)
    @tries[example.description] = {:successes => 0, :tries => 1}
  end

  def example_passed(example)
    increment_success example
  end

  def retry(example)
    increment_tries example
  end

  private
  def increment_success(example)
    previous = @tries[example.description]
    @tries[example.description] = {:successes => (previous[:successes] +1), :tries => previous[:tries]}
  end

  def increment_tries(example)
    previous = @tries[example.description]
    @tries[example.description] = {:successes => previous[:successes], :tries => (previous[:tries] + 1)}
  end
end
