class Routine
  attr_reader :total_time
  attr_accessor :name

  include Mixins

  def initialize(name)
    @name = name
    @events = [] # event {name: "String", time: Integer}
    @total_time = 0
    @start_time = '00:00'
    @finish_time = calculate_finish_time
  end

  ####### Get Methods ##########

  def update_name(original_name)
    event_name = @@prompt.ask("Rename #{original_name} or hit enter", default: '')
    return original_name if event_name == ''

    event_name
  end

  def update_event_time(default = 5)
    @@prompt.slider("How long do you estimate it will take?", min: 5, max: 120, step: 5, default: default, format: "|:slider| %d minutes") 
  end

  def update_routine_time(prompt, range)
    @@prompt.ask("Which #{prompt}? Please provide number in range: #{range}?") do |q|
      q.in range
      q.messages[:range?] = "%{value} is of expected range. Please input a time between #{range}"
    end
  end

  ####### Print Methods ########

  def print_events
    puts asciify(@name.capitalize).colorize(color: @@colors.sample, background: :black)
    print "#{@start_time} |"
    @events.each_with_index do |event, index|
      # Divide by 5 to set smallest possible unit to display as 1 block.
      print "#{'■'.colorize(color: @@colors[index % @@colors.length], background: :black) * (event[:time] / 5)}"
    end
    print "| #{@finish_time}"
    puts "\n\n"
    tabulate_events
  end

  def tabulate_events
    rows = []
    @events.each_with_index do |event, index|
      rows << [
        "#{index + 1}. #{event[:name]}".colorize(color: @@colors[index % @@colors.length], background: :black),
        event[:time]
      ]
    end
    table = Terminal::Table.new do |t|
      t.headings = ['Routine', 'Minutes']
      t.rows = rows
    end
    puts table
    puts
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

  def from_json(events, total_time, start_time, finish_time)
    @events = events
    @total_time = total_time
    @start_time = start_time
    @finish_time = finish_time
  end

  ####### Mutate Methods ########

  def populate_events
    looping = true
    i = @events.length + 1
    while looping
      event_name = @@prompt.ask(
        "What is event number #{i}?\nIf you're done inputting events, just hit enter!", default: ''
      )
      if event_name == ''
        looping = false
      else
        event_time = update_event_time
        @events << { name: event_name, time: event_time }
        i += 1
      end
    end
    update_total_time
  end

  def delete_events
    event_array = select_events('delete')
    return if event_array == []

    selection = events_to_sentence(event_array)
    prompt = "You have selected events: \n[#{selection}]\n\n Are you sure you wish to delete them?"
    return unless user_confirm?(prompt, default: false)

    event_array.each do |event|
      @events.delete(event)
    end
    update_total_time
  end

  def edit_events
    event_array = select_events('edit')
    return if event_array == []

    selection = events_to_sentence(event_array)
    prompt = "You have selected events: \n[#{selection}]\n\n Are you sure you wish to edit them?"
    return unless user_confirm?(prompt)

    update_events(event_array)
  end

  def update_events(event_array)
    event_array.each do |event|
      index = @events.find_index(event)
      event_name = update_name(@events[index][:name])
      event_time = update_event_time(@events[index][:time])
      @events[index][:name] = event_name
      @events[index][:time] = event_time
    end
    update_total_time
  end

  def move_events
    moving_event = select_event('swap')
    follow_event_index = @events.find_index(select_event("place #{moving_event[:name]} in front of"))
    @events.delete(moving_event)
    @events.insert(follow_event_index, moving_event)
  end

  def modify_routine_times(time)
    hours = format_time(update_routine_time("hour to #{time}", '0-23'))
    minutes = format_time(update_routine_time("minute to #{time}", '0-59'))
    if time == 'start'
      @start_time = "#{hours}:#{minutes}"
      @finish_time = calculate_finish_time
    else
      @finish_time = "#{hours}:#{minutes}"
      @start_time =  calculate_finish_time(@finish_time, additive: false)
    end
  end
  ###### Helper Methods #######

  # Take an integer and format it as a 2 digit string
  def format_time(num)
    format('%02d', num)
  end

  # Convert a time string in the format '00:00' into minutes`
  def get_minutes(time_string)
    split_hours, split_minutes = time_string.split(':').map(&:to_i)
    (split_hours * 60) + split_minutes
  end

  # Take an array of events and output a string in a sentence like structure
  def events_to_sentence(event_array)
    array = event_array.map { |e| e[:name] }
    return array.to_s if array.nil? || array.empty?
    return array.join(' ') if array.length == 1

    "#{array[0..-2].join(', ')} and #{array.last}"
  end

  def select_events(prompt)
    choices = generate_event_hash
    @@prompt.multi_select("Select Events to #{prompt}", choices)
  end

  def select_event(prompt)
    choices = generate_event_hash
    @@prompt.select("Select Event to #{prompt}", choices)
  end

  def generate_event_hash
    choices = {}
    @events.each { |event| choices[event[:name]] = event }
    choices
  end

  ######## Calculate Methods ########

  # Defaults to calculating finish time from start time, however if passed 
  # (@finish_time, additive: false) it will instead calculate the start time
  def calculate_finish_time(passed_time = @start_time, additive: true)
    passed_minutes = get_minutes(passed_time)
    return_minutes = (passed_minutes + @total_time) if additive
    return_minutes = (passed_minutes - @total_time) unless additive
    hours = format_time((return_minutes / 60) % 24)
    minutes = format_time(return_minutes % 60)
    "#{hours}:#{minutes}"
  end

  def update_total_time
    total_time = 0
    @events.each do |event|
      total_time += event[:time]
    end
    @total_time = total_time
  end
end
