class Menu
  attr_accessor :routines

  def initialize
    @file_path = './data/routines.json'
    @routines = []
    load_data
    # routine {name: 'name', events: [], total_time: 90}
    # event {name: 'name', time: 5}
  end

  def run
    loop do
      # system 'clear'
      print_welcome
      print_main_menu
      process_main_menu(input_number)
    end
  end

  ########## Print Methods ##########
  def print_welcome
    puts 'Welcome to Routinely'
    print_border
    puts
  end

  def print_main_menu
    print_routines
    puts 'Main Menu: '
    puts "1. Select Routine"
    puts "2. Add Routine"
    puts "3. Delete Routine"
    puts "4. Exit"
  end

  def print_routines
    puts "Your routines:"
    print_border
    if @routines.length.positive?
      @routines.each_with_index do |routine, index|
        puts "#{index + 1}. Name: #{routine.name}, Total time: #{routine.total_time}"
      end
    else
      puts 'No saved routines'
    end
    print_border
  end

  def print_border
    puts '-' * 10
  end

  ########## Get Methods ##########
  def input_number
    gets.to_i
  end

  def input_string
    gets.strip
  end

  ########## Logic Methods ##########
  def process_main_menu(selection)
    case selection
    when 1
      puts "Select Routine:"
      @routines[input_number - 1].view_routine
    when 2
      puts "Name your routine:"
      add_routine(input_string)
    when 3
      puts "Select Routine (delete):"
    when 4
      puts "See you next time!"
      save_routines
      exit
    end
  end

  ########## Mutate Methods ##########
  def add_routine(input)
    @routines << Routine.new(input)
    @routines.last.populate_events
  end

  ###########      I/O      ###########
  def save_routines
    File.open(@file_path, 'w+') # Create new file with read/write permissions
    File.write(@file_path, @routines.to_json)
  end

  def load_data
    return unless File.exist?(@file_path)
    json_data = JSON.parse(File.read(@file_path), symbolize_names: true)
    json_data.each do |obj|
      @routines << Routine.new(
        obj[:name],
        obj[:events],
        obj[:total_time],
        obj[:start_time],
        obj[:finish_time])
    end
  end
end
