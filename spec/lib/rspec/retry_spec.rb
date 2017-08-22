require 'spec_helper'

describe RSpec::Retry do
  def count
    @count ||= 0
    @count
  end

  def count_up
    @count ||= 0
    @count += 1
  end

  def set_expectations(expectations)
    @expectations = expectations
  end

  def shift_expectation
    @expectations.shift
  end

  class RetryError < StandardError; end
  class RetryChildError < RetryError; end
  class HardFailError < StandardError; end
  class HardFailChildError < HardFailError; end
  class OtherError < StandardError; end;
  class SharedError < StandardError; end;

  before(:all) do
    ENV.delete('RSPEC_RETRY_RETRY_COUNT')
  end

  context 'no retry option' do
    it 'should work' do
      expect(true).to be(true)
    end
  end

  context 'with retry option' do
    before(:each) { count_up }

    context do
      before(:all) { set_expectations([false, false, true]) }

      it 'should run example until :retry times', :retry => 3 do
        expect(true).to be(shift_expectation)
        expect(count).to eq(3)
      end
    end

    context do
      before(:all) { set_expectations([false, true, false]) }

      it 'should stop retrying if  example is succeeded', :retry => 3 do
        expect(true).to be(shift_expectation)
        expect(count).to eq(2)
      end
    end

    context 'with :retry => 0' do
      after(:all) { @@this_ran_once = nil }
      it 'should still run once', retry: 0 do
        @@this_ran_once = true
      end

      it 'should run have run once' do
        expect(@@this_ran_once).to be true
      end
    end

    context 'with the environment variable RSPEC_RETRY_RETRY_COUNT' do
      before(:all) do
        set_expectations([false, false, true])
        ENV['RSPEC_RETRY_RETRY_COUNT'] = '3'
      end

      after(:all) do
        ENV.delete('RSPEC_RETRY_RETRY_COUNT')
      end

      it 'should override the retry count set in an example', :retry => 2 do
        expect(true).to be(shift_expectation)
        expect(count).to eq(3)
      end
    end

    describe "with a list of exceptions to immediately fail on", :retry => 2, :exceptions_to_hard_fail => [HardFailError] do
      context "the example throws an exception contained in the hard fail list" do
        it "does not retry" do
          expect(count).to be < 2
          pending "This should fail with a count of 1: Count was #{count}"
          raise HardFailError unless count > 1
        end
      end

      context "the example throws a child of an exception contained in the hard fail list" do
        it "does not retry" do
          expect(count).to be < 2
          pending "This should fail with a count of 1: Count was #{count}"
          raise HardFailChildError unless count > 1
        end
      end

      context "the throws an exception not contained in the hard fail list" do
        it "retries the maximum number of times" do
          raise OtherError unless count > 1
          expect(count).to eq(2)
        end
      end
    end

    describe "with a list of exceptions to retry on", :retry => 2, :exceptions_to_retry => [RetryError] do
      context "the example throws an exception contained in the retry list" do
        it "retries the maximum number of times" do
          raise RetryError unless count > 1
          expect(count).to eq(2)
        end
      end

      context "the example throws a child of an exception contained in the retry list" do
        it "retries the maximum number of times" do
          raise RetryChildError unless count > 1
          expect(count).to eq(2)
        end
      end

      context "the example fails (with an exception not in the retry list)" do
        it "only runs once" do
          set_expectations([false])
          expect(count).to eq(1)
        end
      end
    end

    describe "with both hard fail and retry list of exceptions", :retry => 2, :exceptions_to_retry => [SharedError, RetryError], :exceptions_to_hard_fail => [SharedError, HardFailError] do
      context "the exception thrown exists in both lists" do
        it "does not retry because the hard fail list takes precedence" do
          expect(count).to be < 2
          pending "This should fail with a count of 1: Count was #{count}"
          raise SharedError unless count > 1
        end
      end

      context "the example throws an exception contained in the hard fail list" do
        it "does not retry because the hard fail list takes precedence" do
          expect(count).to be < 2
          pending "This should fail with a count of 1: Count was #{count}"
          raise HardFailError unless count > 1
        end
      end

      context "the example throws an exception contained in the retry list" do
        it "retries the maximum number of times because the hard fail list doesn't affect this exception" do
          raise RetryError unless count > 1
          expect(count).to eq(2)
        end
      end

      context "the example throws an exception contained in neither list" do
        it "does not retry because the the exception is not in the retry list" do
          expect(count).to be < 2
          pending "This should fail with a count of 1: Count was #{count}"
          raise OtherError unless count > 1
        end
      end
    end
  end

  describe 'clearing lets' do
    before(:all) do
      @control = true
    end

    let(:let_based_on_control) { @control }

    after do
      @control = false
    end

    it 'should clear the let when the test fails so it can be reset', :retry => 2 do
      expect(let_based_on_control).to be(false)
    end

    it 'should not clear the let when the test fails', :retry => 2, :clear_lets_on_failure => false do
      expect(let_based_on_control).to be(!@control)
    end
  end

  describe 'running example.run_with_retry in an around filter', retry: 2 do
    before(:each) { count_up }
    before(:all) do
      set_expectations([false, false, true])
    end

    it 'allows retry options to be overridden', :overridden do
      expect(RSpec.current_example.metadata[:retry]).to eq(3)
    end

    it 'uses the overridden options', :overridden do
      expect(true).to be(shift_expectation)
      expect(count).to eq(3)
    end
  end

  describe 'calling retry_callback between retries', retry: 2 do
    before(:all) do
      RSpec.configuration.retry_callback = proc do |example|
        @retry_callback_called = true
        @example = example
      end
    end

    after(:all) do
      RSpec.configuration.retry_callback = nil
    end

    context 'if failure' do
      before(:all) do
        @retry_callback_called = false
        @example = nil
        @retry_attempts = 0
      end

      it 'should call retry callback', with_some: 'metadata' do |example|
        if @retry_attempts == 0
          @retry_attempts += 1
          expect(@retry_callback_called).to be(false)
          expect(@example).to eq(nil)
          raise "let's retry once!"
        elsif @retry_attempts > 0
          expect(@retry_callback_called).to be(true)
          expect(@example).to eq(example)
          expect(@example.metadata[:with_some]).to eq('metadata')
        end
      end
    end

    context 'does not call retry_callback if no errors' do
      before(:all) do
        @retry_callback_called = false
        @example = nil
      end

      after do
        expect(@retry_callback_called).to be(false)
        expect(@example).to be_nil
      end

      it { true }
    end
  end

  describe 'output in verbose mode' do

    line_1 = __LINE__ + 8
    line_2 = __LINE__ + 11
    let(:group) do
      RSpec.describe 'ExampleGroup', retry: 2 do
        after do
          fail 'broken after hook'
        end

        it 'passes' do
          true
        end

        it 'fails' do
          fail 'broken spec'
        end
      end
    end

    it 'outputs failures correctly' do
      RSpec.configuration.output_stream = output = StringIO.new
      RSpec.configuration.verbose_retry = true
      RSpec.configuration.display_try_failure_messages = true
      expect {
        group.run RSpec.configuration.reporter
      }.to change { output.string }.to a_string_including <<-STRING.gsub(/^\s+\| ?/, '')
        | 1st Try error in ./spec/lib/rspec/retry_spec.rb:#{line_1}:
        | broken after hook
        |
        | RSpec::Retry: 2nd try ./spec/lib/rspec/retry_spec.rb:#{line_1}
        | F
        | 1st Try error in ./spec/lib/rspec/retry_spec.rb:#{line_2}:
        | broken spec
        | broken after hook
        |
        | RSpec::Retry: 2nd try ./spec/lib/rspec/retry_spec.rb:#{line_2}
      STRING
    end
  end
end
