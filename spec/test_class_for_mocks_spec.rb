require 'spec_helper'

RSpec.describe TestClassForMocks do

  context 'Scenario 1' do
    before do

      @fixture = TestClassForMocks.new

    end

    it 'should pass current expectations' do

      var_2166690320 = [2, 3, 4, 5]

      allow_any_instance_of(TestMockSubClass).to receive(:test_method).and_return("a return string")
      allow_any_instance_of(TestMockSubClass).to receive(:increment_val).and_return(2, 3, 4, 5)

      # TestClassForMocks#method_with_assign= when passed params2 = "test" should return test
      expect( @fixture.method_with_assign=("test") ).to eq("test")

      # TestClassForMocks#method_with_usage  should return a return string
      expect( @fixture.method_with_usage ).to eq("a return string")

      # TestClassForMocks#method_with_usage2  should return [2, 3, 4, 5]
      expect( @fixture.method_with_usage2 ).to eq([2, 3, 4, 5])

      # TestClassForMocks#method_with_usage4  should return a return string
      expect( @fixture.method_with_usage4 ).to eq("a return string")

    end
  end

  context 'Scenario 2' do
    before do

      @fixture = TestClassForMocks.new

    end

    it 'should pass current expectations' do

      var_2166592900 = {val: 1, str: "hello world", message: "a message"}

      allow_any_instance_of(TestMockSubClass).to receive(:return_hash).and_return(var_2166592900)

      # TestClassForMocks#method_with_usage3 when passed message = "a message" should return {:val=>1, :str=>"hello world", :message=>"a message"}
      expect( @fixture.method_with_usage3("a message") ).to eq(var_2166592900)

    end
  end

end
