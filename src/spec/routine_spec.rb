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

  describe '#from_JSON' do
    before(:each) do
      events = [{ name: 'event1', time: 15 }, { name: 'event2', time: 45 }]
      total_time = 160
      start_time = '00:00'
      finish_time = '02:40'
      routine.from_json(events, total_time, start_time, finish_time)
    end

    it 'should add events correctly' do
      expect(routine.inspect).to include('test')
    end

    it 'should add events correctly' do
      expect(routine.inspect).to include({ name: 'event1', time: 15 }.to_s)
    end

    it 'should add total time correctly' do
      expect(routine.inspect).to include(160.to_s)
    end

    it 'should add start time correctly' do
      expect(routine.inspect).to include('00:00')
    end

    it 'should add finish time correctly' do
      expect(routine.inspect).to include('02:40')
    end
  end

  describe 'time calculations' do
    context 'modify start/end time' do
      before(:each) do
        events = [{ name: 'event1', time: 15 }, { name: 'event2', time: 45 }]
        total_time = 160
        start_time = '00:00'
        finish_time = '00:00'
        routine.from_json(events, total_time, start_time, finish_time)
      end

      context 'modify start time' do
        it 'should output the correct end time from a default string' do
          expect(routine.calculate_finish_time).to eq('02:40')
        end

        it 'should output the correct end time from a specified string' do
          expect(routine.calculate_finish_time('12:00')).to eq('14:40')
        end

        it 'should output the correct end time when number of minutes equals +1 hour' do
          expect(routine.calculate_finish_time('12:30')).to eq('15:10')
        end

        it 'should output the correct end time when moving past midnight' do
          expect(routine.calculate_finish_time('23:00')).to eq('01:40')
        end
      end

      context 'modify end time' do
        it 'should output the correct start time from a specified string' do
          expect(routine.calculate_finish_time('12:00', additive: false)).to eq('09:20')
        end

        it 'should output the correct start time when number of minutes equals +1 hour' do
          expect(routine.calculate_finish_time('12:30', additive: false)).to eq('09:50')
        end

        it 'should output the correct start time when moving past midnight' do
          expect(routine.calculate_finish_time('01:00', additive: false)).to eq('22:20')
        end

        it 'should output the correct start time when moving past midnight' do
          expect(routine.calculate_finish_time('02:40', additive: false)).to eq('00:00')
        end
      end
    end
  end
end
