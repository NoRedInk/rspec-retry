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

    describe "with a list of exceptions", :retry => 2, :exceptions_to_retry => [NoMethodError] do
      context "the example throws an exception contained in the retry list" do
        it "retries the maximum number of times" do
          raise NoMethodError unless count > 1
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
end
