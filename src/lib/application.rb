class App
  attr_accessor :routines

  def initialize
    @routines = []
    # routine {name: 'name', total_time: 90}
  end

  def run
    print_welcome
    loop do
      print_main_menu
      process_main_menu(get_selection)
    end
  end

  ########## Print Methods ##########
  def print_welcome
    puts 'Welcome to Routinely'
    puts
  end

  def print_main_menu
    pp @routines
    puts 'Main Menu: '
    puts "1. Select Routine"
    puts "2. Add Routine"
    puts "3. Delete Routine"
    puts "4. Exit"
  end

  ########## Get Mehtods ##########
  def get_selection
    gets.to_i
  end

  def get_input
    gets.strip
  end

  ########## Logic Methods ##########
  def process_main_menu(selection)
    case selection
    when 1
    when 2
      puts "Name your routine:"
      add_routine(get_input)
    when 3
    when 4
      exit
    end
  end

  ########## Mutate Methods ##########
  def add_routine(input)
    @routines << { name: input, total_time: 0 }
  end
end
