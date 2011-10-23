require File.dirname(__FILE__) + '/spec_helper'

describe 'output' do
  it 'outputs integers' do
    run_program("output 1").should == {
      :exit_status => 0,
      :stdout => "1\n",
      :stderr => ""
    }
  end

  it 'outputs reals' do
    run_program("output 1.5").should == {
      :exit_status => 0,
      :stdout => "1.5\n",
      :stderr => ""
    }
  end

  it 'outputs booleans' do
    ['true', 'false'].each do |val|
      run_program("output #{val}").should == {
        :exit_status => 0,
        :stdout => "#{val}\n",
        :stderr => ""
      }
    end
  end

  it 'puts each value on its own line' do
    run_program("output 1 ; output 1.5 ; output true").should == {
      :exit_status => 0,
      :stdout => "1\n1.5\ntrue\n",
      :stderr => ""
    }
  end
end
