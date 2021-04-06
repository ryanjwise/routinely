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
        event_time = @@prompt.slider("How long do you estimate it will take?", min: 5, max:120, step: 5, default: 5, format: "|:slider| %d minutes") 
        @events << {name: event_name, time: event_time}
        @total_time += event_time
        i += 1
      end
    end
    @finish_time = calculate_time
  end

  def delete_events
    event_array = select_events
    selection = to_sentence(event_array.map { |e| e[:name] })
    prompt = "You have selected events: \n[#{selection}]\n\n Are you sure you wish to delete them?"
    return unless @@prompt.yes?(prompt) do |q|
      q.default false
    end
    event_array.each do |event|
      @events.delete(event)
    end
  end

  def to_sentence(array)
    return array.to_s if array.nil? || array.empty?
    return array.join(" ") if array.length == 1

    "#{array[0..-2].join(', ')} and #{array.last}"
  end

  def select_events
    choices = {}
    @events.each_with_index { |event, index| choices[event[:name]] = event }
    pp @@prompt.multi_select("Select Events to Delete", choices)
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
