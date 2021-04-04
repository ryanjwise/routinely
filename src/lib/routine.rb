class Routine < Menu
  attr_reader :name, :total_time

  def initialize(name)
    @name = name
    @events = []
    # event {name: event_name, time: event_time}
    @total_time = 0
  end

  def populate_events
    looping = true
    i = 1
    while looping
      puts "What is event number #{i}? Hit enter to stop adding."
      event_name = input_string
      if event_name == ''
        looping = false
      else
        puts 'How long do you estimate task will take? (minutes)'
        event_time = input_number
        @events << {name: event_name, time: event_time}
        @total_time += event_time
        i += 1
      end
    end
  end

  def view_routine
    puts @name.capitalize
    print_border
    @events.each do |event|
      print "#{'-' * event[:time]}|"
    end
  end
end
