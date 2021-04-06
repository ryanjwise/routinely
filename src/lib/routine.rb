class Routine
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
    i = @events.length + 1
    while looping
      event_name = @@prompt.ask("What is event number #{i}?\nIf you're done inputting events, just hit enter!", default: '')
      if event_name == ''
        looping = false
      else
        event_time = set_time
        @events << {name: event_name, time: event_time}
        @total_time += event_time
        i += 1
      end
    end
    @finish_time = calculate_time
  end

  def delete_events
    event_array = select_events('delete')
    selection = events_to_sentence(event_array)
    prompt = "You have selected events: \n[#{selection}]\n\n Are you sure you wish to delete them?"
    return unless @@prompt.yes?(prompt) do |q|
      q.default false
    end
    event_array.each do |event|
      @events.delete(event)
    end
  end

  def edit_events
    event_array = select_events('edit')
    pp event_array
    return if event_array == []
    selection = events_to_sentence(event_array)
    prompt = "You have selected events: \n[#{selection}]\n\n Are you sure you wish to edit them?"
    return unless @@prompt.yes?(prompt) do |q|
      q.default true
    end

    event_array.each do |event|
      index = @events.find_index(event)
      event_name = change_name(@events[index][:name])
      event_time = set_time(@events[index][:time])
      @events[index][:name] = event_name
      @events[index][:time] = event_time
    end
  end

  def change_name(original_name)
    event_name = @@prompt.ask("Rename #{original_name} or hit enter", default: '')
    return original_name if event_name == ''

    event_name
  end

  def set_time(default = 5)
    @@prompt.slider("How long do you estimate it will take?", min: 5, max:120, step: 5, default: default, format: "|:slider| %d minutes") 
  end

  def events_to_sentence(event_array)
    array = event_array.map{ |e| e[:name] }
    return array.to_s if array.nil? || array.empty?
    return array.join(' ') if array.length == 1

    "#{array[0..-2].join(', ')} and #{array.last}"
  end

  def select_events(prompt)
    choices = {}
    @events.each_with_index { |event, index| choices[event[:name]] = event }
    @@prompt.multi_select("Select Events to #{prompt}", choices)
  end

  def view_routine
    puts @name.capitalize
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
