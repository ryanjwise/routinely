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
      main_menu
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

  def main_menu
    menu_options = [
      "Select Routine",
      "Rename Routine",
      "Add Routine",
      "Delete Routine",
      "Exit"
    ]
    process_main_menu(@@prompt.select("Main Menu:", menu_options))
  end

  ########## Logic Methods ##########
  def process_main_menu(selection)
    case selection
    when "Select Routine"
      view_routine
    when "Rename Routine"
      rename_routine
    when "Add Routine"
      puts "Name your routine:"
      add_routine(input_string)
    when "Delete Routine"
      puts "Select Routine (delete):"
      delete_routine(input_number - 1)
    when "Exit"
      puts "See you next time!"
      save_routines
      exit
    when "Debug"
      puts "---Debug---"
      @routines.delete_at(1)
    end
  end

  def view_routine
    choices = {}
    @routines.each_with_index { |routine, index| choices[routine.name] = routine }
    @@prompt.select("Select Routine", choices).view_routine
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
