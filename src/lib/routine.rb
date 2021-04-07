class Routine
  attr_reader :total_time
  attr_accessor :name

  @@prompt = TTY::Prompt.new
  @@colors = [
    :light_black,
    :red,
    :light_red,
    :green,
    :light_green,
    :yellow,
    :light_yellow,
    :blue,
    :light_blue,
    :magenta,
    :light_magenta,
    :cyan,
    :light_cyan
  ]

  def initialize(
    name,
    events = [],
    total_time = 0,
    start_time = '00:00',
    finish_time = '00:00'
  )
    @name = name
    @events = events
    # event {name: event_name, time: event_time}
    @total_time = total_time
    @start_time = start_time
    @finish_time = finish_time
    update_total_time
    # calculate_finish_time
  end

  ####### Get Methods ##########

  def update_name(original_name)
    event_name = @@prompt.ask("Rename #{original_name} or hit enter", default: '')
    return original_name if event_name == ''

    event_name
  end

  def update_time(default = 5)
    @@prompt.slider("How long do you estimate it will take?", min: 5, max:120, step: 5, default: default, format: "|:slider| %d minutes") 
  end

  ####### Print Methods ########

  def print_events
    puts @name.capitalize
    print "#{@start_time} |"
    @events.each_with_index do |event, index|
      print "#{'■'.colorize(:color => @@colors[index % @@colors.length], :background => :black) * (event[:time] / 5)}"
    end
    print "| #{@finish_time}"
    puts "\n\n"
    tabulate_events
  end

  def tabulate_events
    rows = []
    @events.each_with_index do |event, index|
      rows << [
        "#{index + 1}. #{event[:name]}".colorize(:color => @@colors[index % @@colors.length], :background => :black),
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

  ####### Mutate Methods ########

  def populate_events
    looping = true
    i = @events.length + 1
    while looping
      event_name = @@prompt.ask(
        "What is event number #{i}?\nIf you're done inputting events, just hit enter!", default: '')
      if event_name == ''
        looping = false
      else
        event_time = update_time
        @events << { name: event_name, time: event_time }
        i += 1
      end
    end
    update_total_time
    # @finish_time = calculate_total_time
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
      event_time = update_time(@events[index][:time])
      @events[index][:name] = event_name
      @events[index][:time] = event_time
    end
    update_total_time
  end

  def move_events
    moving_event = (select_event('swap'))
    follow_event_index = @events.find_index(select_event("place #{moving_event[:name]} in front of"))
    @events.delete(moving_event)
    @events.insert(follow_event_index, moving_event)
  end

  ###### Helper Methods #######
  def events_to_sentence(event_array)
    array = event_array.map{ |e| e[:name] }
    return array.to_s if array.nil? || array.empty?
    return array.join(' ') if array.length == 1

    "#{array[0..-2].join(', ')} and #{array.last}"
  end

  def user_confirm?(prompt, default: true)
    @@prompt.yes?(prompt) do |q|
      q.default default
    end
  end

  def select_events(prompt)
    choices = {}
    @events.each_with_index { |event, index| choices[event[:name]] = event }
    @@prompt.multi_select("Select Events to #{prompt}", choices)
  end

  def select_event(prompt)
    choices = {}
    @events.each_with_index { |event, index| choices[event[:name]] = event }
    @@prompt.select("Select Event to #{prompt}", choices)
  end

  ######## Calculate Methods ########

  def calculate_start_time
    # [@total_time / 60, @total_time % 60].join(':').to_s
    # total_time
    # finish_time
  end

  def calculate_finish_time
    # [@total_time / 60, @total_time % 60].join(':').to_s
    # total_time
    # start_time '00:00'
    total_hours = @total_time / 60
    total_minutes = @total_time % 60
    start_hours, start_minutes =  @start_time.split(':') # Split time string into seperate hour/minute vars.

    return_minutes = (total_minutes + start_minutes) 
    if return_minutes >= 60 # If 60 minutes or greater increment hours and return remaining minutes
      start_hours += 1 # Currently may increment hours beyond 23....
      return_minutes %= 60
    end
    return_hours = (total_hours + start_hours) % 24 # should return hours in day, looping at each day
    @finish_time = "#{return_hours}:#{return_minutes}"
    user_confirm?('debug')
  end

  def update_total_time
    total_time = 0
    @events.each do |event|
      total_time += event[:time]
    end
    @total_time = total_time
  end
end
