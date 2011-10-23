require File.dirname(__FILE__) + '/spec_helper'

describe 'arithmetic' do
  describe '+ operator' do
    it 'sums integers' do
      run_program("output 1 + 2").should == {
        :exit_status => 0,
        :stdout => "3\n",
        :stderr => ""
      }
    end

    it 'sums reals' do
      run_program("output 1.2 + 2.3").should == {
        :exit_status => 0,
        :stdout => "3.5\n",
        :stderr => ""
      }
    end

    it 'sums integers with reals' do
      run_program("output 1 + 2.3 ; output 1.2 + 2").should == {
        :exit_status => 0,
        :stdout => "3.3\n3.2\n",
        :stderr => ""
      }
    end
  end

  describe '* operator' do
    it 'multiplies integers' do
      run_program("output 2 * 3").should == {
        :exit_status => 0,
        :stdout => "6\n",
        :stderr => ""
      }
    end

    it 'multiplies reals' do
      run_program("output 1.2 * 2.3").should == {
        :exit_status => 0,
        :stdout => "2.76\n",
        :stderr => ""
      }
    end

    it 'multiplies integers with reals' do
      run_program("output 2 * 1.3 ; output 1.2 * 3").should == {
        :exit_status => 0,
        :stdout => "2.6\n3.6\n",
        :stderr => ""
      }
    end
  end

  describe '/ operator' do
    it 'divides integers' do
      run_program("output 8 / 3").should == {
        :exit_status => 0,
        :stdout => "2\n",
        :stderr => ""
      }
    end

    it 'divides reals' do
      run_program("output 1.43 / 1.3").should == {
        :exit_status => 0,
        :stdout => "1.1\n",
        :stderr => ""
      }
    end

    it 'divides integers with reals' do
      run_program("output 6 / 1.5 ; output 1.2 / 4").should == {
        :exit_status => 0,
        :stdout => "4.0\n0.3\n",
        :stderr => ""
      }
    end
  end
end
