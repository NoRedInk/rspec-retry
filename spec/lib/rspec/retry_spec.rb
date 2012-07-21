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
      true.should be_true
    end
  end

  context 'with retry option' do
    before(:each) { count_up }

    context do
      before(:all) { set_expectations([false, false, true]) }

      it 'should run example until :retry times', :retry => 3 do
        true.should == shift_expectation
        count.should == 3
      end
    end

    context do
      before(:all) { set_expectations([false, true, false]) }

      it 'should stop retrying if  example is succeeded', :retry => 3 do
        true.should == shift_expectation
        count.should == 2
      end
    end

    it 'should success randomly', :retry => 3 do
      rand(3).should == 1
    end
  end
end
