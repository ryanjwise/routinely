class Routine < Menu
  attr_reader :total_time
  attr_accessor :name

  @@prompt = TTY::Prompt.new

  def initialize(
    name,
    events = [],
    total_time = 0,
    start_time = '0000',
    finish_time = '0000'
  )
    @name = name
    @events = events
    # event {name: event_name, time: event_time}
    @total_time = total_time
    @start_time = start_time
    @finish_time = finish_time
    calculate_time
  end

  def populate_events
    looping = true
    i = 1
    while looping
      event_name = @@prompt.ask("What is event number #{i}?\nIf you're done inputting events, just hit enter!", default: '')
      # puts "What is event number #{i}? Hit enter to stop adding."
      # event_name = input_string
      if event_name == ''
        looping = false
      else
        event_time = @@prompt.slider("How long do you estimate it will take?", min: 5, max:120, step: 5, default: 5, format: "|:slider| %d minutes") 
        # puts 'How long do you estimate task will take? (minutes)'
        # event_time = input_number
        @events << {name: event_name, time: event_time}
        @total_time += event_time
        i += 1
      end
    end
    @finish_time = calculate_time
  end

  def view_routine
    puts @name.capitalize
    print_border
    print @start_time
    @events.each do |event|
      print "#{'-' * event[:time]}|"
    end
    print @finish_time
    puts
  end

  def calculate_time
    [@total_time / 60, @total_time % 60].join(':').to_s
  end

  # Needs the (opt) parameter for some reason, no idea why
  def to_json(opt)
    {
      name: @name,
      events: @events,
      total_time: @total_time,
      start_time: @start_time,
      finish_time: @finish_time
    }.to_json
  end
end
