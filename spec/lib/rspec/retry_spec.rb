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
