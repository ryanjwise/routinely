require_relative '../lib/routine'

RSpec.describe Routine do
  subject(:routine) do
    Routine.new('test')
  end

  describe 'Class Testing' do 
    it 'should be an instance of routine' do
      expect(routine).to be_a Routine
    end
  end
end