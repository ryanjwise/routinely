require_relative '../lib/application'

# Clear arguments
ARGV.clear

RSpec.describe App do
  subject(:app) do
    described_class.new
  end

  describe 'Class Testing' do
    it 'should be an instance of App' do
      expect(app).to be_a App
    end

    it 'should have an empty routine list' do
      expect(app.routines).to eq []
    end
  end
end
