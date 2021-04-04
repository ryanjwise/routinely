require_relative '../lib/application'
require_relative '../lib/routine'

# Clear arguments
ARGV.clear

RSpec.describe Menu do
  subject(:menu) do
    described_class.new
  end

  describe 'Class Testing' do
    it 'should be an instance of menu' do
      expect(menu).to be_a Menu
    end

    it 'should have an empty routine list' do
      expect(menu.routines).to eq []
    end
  end

  describe 'Menu Navigation' do
    let(:input) { StringIO.new('1') }
    it 'should get input from the user' do
      $stdin = input
      expect(menu.input_number).to eq(1)
    end
  end

  describe 'Routine CRUD' do
    before
    it 'should be able to add new routine items' do
      menu.add_routine('test routine')
      expect(menu.routines.last[:name]).to eq('test routine')
    end
  end
end
