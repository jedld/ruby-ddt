# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe TestClass3 do
  context 'Scenario 1' do
    before do
      another_object = TestClass1.new('test')
      var_2172775300 = { hello: 'world', test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: { yes: true, obj: another_object } }
      testclass1 = TestClass1.new(var_2172775300)
      testclass2 = TestClass2.new('This is message 2', nil)
      @fixture = TestClass3.new(testclass1, testclass2)
    end

    it 'should pass current expectations' do
      # TestClass3#show_messages  should return awesome!!!
      expect(@fixture.show_messages).to eq('awesome!!!')
    end
  end

  context 'Scenario 2' do
    before do
      another_object = TestClass1.new('test')
      var_2172775300 = { hello: 'world', test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: { yes: true, obj: another_object } }
      testclass1 = TestClass1.new(var_2172775300)
      testclass2 = TestClass2.new('This is message 2', nil)
      @fixture = TestClass3.new(testclass1, testclass2)
    end

    it 'should pass current expectations' do
      # TestClass3#show_messages  should return awesome!!!
      expect(@fixture.show_messages).to eq('awesome!!!')
    end
  end

end
