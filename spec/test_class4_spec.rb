require 'spec_helper'

RSpec.describe TestClass4 do

  context 'Scenario 1' do
    before do

      var_2158495560 = "test"
      var_2158363380 = Proc.new { 
            "test"
      }


      @fixture = TestClass4.new &var_2158363380

    end

    it 'should pass current expectations' do

    end
  end

end
