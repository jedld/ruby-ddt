require 'spec_helper'

RSpec.describe Pretentious::Generator do

  context 'Pretentious::Deconstructor#build_tree' do

    before do
      @fixture = Pretentious::Generator.new
      Pretentious::Generator.test_generator = Pretentious::RspecGenerator
    end

    it "classes should have a stub class section" do
      Fibonacci._stub(String)
      expect(Fibonacci._get_mock_classes).to eq([String])
    end

    it "tracks object calls" do
      result = Pretentious::Generator.generate_for(Fibonacci) do
        Fibonacci.say_hello
      end
      expect(result).to eq({
        Fibonacci =>{output: "require 'spec_helper'\n\nRSpec.describe Fibonacci do\n\n    it 'should pass current expectations' do\n\n      # Fibonacci::say_hello  should return hello\n      expect( Fibonacci.say_hello ).to eq(\"hello\")\n\n    end\nend\n",
                     generator: Pretentious::RspecGenerator}})
    end

  end

end
