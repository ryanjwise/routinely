class Menu
  attr_accessor :routines

  @@prompt = TTY::Prompt.new
  def initialize
    @file_path = './data/routines.json'
    @routines = []
    load_data # Populates @routines, therefor must follow in initialize
  end

  def run
    loop do
      system 'clear'
      print_welcome
      print_routines
      main_menu_options
    end
  end

  ########## Print Methods ##########

  def print_welcome
    puts 'Welcome to Routinely'
    print_border
    puts
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
    # gets.strip
    @@prompt.ask("") do |q|
      q.modify :strip, :down
    end
  end

  def main_menu_options
    menu_options = [
      "Select Routine",
      "Rename Routine",
      "Add Routine",
      "Delete Routine",
      "Exit"
    ]
    process_main_menu(@@prompt.select("Main Menu:", menu_options))
  end

  def routines_menu_options
    menu_options = [
      { name: 'Set start time', disabled: '(Under Construction)' },
      { name: 'Set end time', disabled: '(Under Construction)' },
      { name: 'Move blocks', disabled: '(Under Construction)' },
      { name: 'Edit Blocks', },
      { name: 'Delete Blocks', },
      { name: 'Add Blocks' },
      { name: 'Back to main menu' },
      { name: 'Exit' }
    ]
    @@prompt.select('What would you like to do?', menu_options)
  end

  def routines_menu
    routine = select_routine
    looping = true
    while looping
      # system 'clear'
      routine.view_routine
      selection = routines_menu_options
      process_routine_menu(routine, selection)
      looping = false if selection == 'Back to main menu'
    end
  end

  ########## Logic Methods ##########
  def process_main_menu(selection)
    case selection
    when "Select Routine"
      routines_menu
    when "Rename Routine"
      rename_routine
    when "Add Routine"
      puts "Name your routine:"
      add_routine(input_string)
    when "Delete Routine"
      puts "Select Routine (delete):"
      delete_routine(input_number - 1)
    when "Exit"
      exit_program
    when "Debug"
      puts "---Debug---"
      @routines.delete_at(1)
    end
  end

  def process_routine_menu(routine, selection)
    case selection
    when "Set start time"
    when "Set end time"
    when "Move blocks"
    when "Edit Blocks"
      routine.edit_events
    when "Delete Blocks"
      routine.delete_events
    when "Add Blocks"
      routine.populate_events
    when "Back to main menu"
      # Handled in menu
    when "Exit"
      exit_program
    end
  end

  def select_routine
    choices = {}
    @routines.each_with_index { |routine, index| choices[routine.name] = routine }
    @@prompt.select("Select Routine", choices)
  end

  def exit_program
    puts "See you next time!"
    save_routines
    exit
  end

  ########## Mutate Methods ##########
  def add_routine(input)
    @routines << Routine.new(input)
    @routines.last.populate_events
  end

  def delete_routine(input)
    @routines.delete_at(input)
  end

  def rename_routine
    puts "Select Routine:"
    selection = @routines[input_number - 1]
    puts "You have selected #{selection.name}, what would you like to rename it? Push Enter to cancel."
    input = input_string
    selection.name = input unless input == ''
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
