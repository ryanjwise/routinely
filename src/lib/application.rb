class Menu
  attr_accessor :routines

  def initialize
    @routines = []
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
      exit
    end
  end

  ########## Mutate Methods ##########
  def add_routine(input)
    @routines << Routine.new(input)
    @routines.last.populate_events
  end
end
