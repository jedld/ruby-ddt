# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe Meme do
  context 'Scenario 1' do
    before do
      @fixture = Meme.new
    end

    it 'should pass current expectations' do
      # Meme#i_can_has_cheezburger?  should return 'OHAI!'
      expect(@fixture.i_can_has_cheezburger?).to eq('OHAI!')

      # Meme#will_it_blend?  should return 'YES!'
      expect(@fixture.will_it_blend?).to eq('YES!')
    end
  end
end