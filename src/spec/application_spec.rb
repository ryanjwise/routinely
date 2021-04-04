require_relative '../lib/application'

# Clear arguments
ARGV.clear

RSpec.describe Menu do
  subject(:app) do
    described_class.new
  end

  describe 'Class Testing' do
    it 'should be an instance of App' do
      expect(app).to be_a Menu
    end

    it 'should have an empty routine list' do
      expect(app.routines).to eq []
    end
  end

  describe 'Menu Navigation' do
    let(:input) { StringIO.new('1') }
    it 'should get input from the user' do
      $stdin = input
      expect(app.get_selection).to eq(1)
    end
  end

  describe 'Routine CRUD' do
    before
    it 'should be able to add new routine items' do
      app.add_routine('test routine')
      expect(app.routines.last).to eq({name: 'test routine', total_time: 0})
    end
  end
end
