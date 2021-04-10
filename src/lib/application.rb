class Menu
  attr_reader :routines
  
  include Mixins

  def initialize
    @file_path = './data/routines.json'
    @routines = []
    load_data # Populates @routines, therefor must follow in initialize
  end

  ####### Core Application Loops ########

  def run
    system 'clear'
    print_welcome
    loop do
      print_routines
      main_menu_options
      system 'clear'
    end
  end

  def routines_menu
    routine = select_routine
    return if routine == 'Cancel'

    looping = true
    while looping
      system 'clear'
      routine.print_events
      selection = routines_menu_options
      process_routine_menu(routine, selection)
      looping = false if selection == 'Back to main menu'
    end
  end

  ########## Print Methods ##########

  def print_border
    puts '-' * 10
  end

  def print_welcome
    puts asciify('Welcome to Routinely').colorize(color: @@colors.sample, background: :black)
  end

  def print_routines
    if @routines.length.positive?
      rows = []
      @routines.each_with_index do |routine, index|
        rows << [
          "#{index + 1}. #{routine.name}",
          routine.total_time,
          "#{'■'.colorize(:color => :light_blue, :background => :black) * (routine.total_time / 5)}"
        ]
      end
      table = Terminal::Table.new do |t|
        t.headings = ['Routine', 'Minutes', 'Time']
        t.rows = rows
        t.style = { border_left: false, border_right: false }
      end
      puts table
    else
      print_border
      puts 'No saved routines'
      print_border
    end
  end

  ########## Get Methods ##########

  # Get a string from the user, pass a prompt, or act like a regular gets method
  def input_string(query = '')
    @@prompt.ask(query) do |q|
      q.modify :strip, :down
    end
  end

  def select_routine
    choices = {}
    @routines.each { |routine| choices[routine.name] = routine }
    choices[:Cancel] = 'Cancel'
    @@prompt.select('Select Routine: ', choices, default: 'Cancel')
  end

  def main_menu_options
    menu_options = [
      'Select Routine',
      'Rename Routine',
      'Add Routine',
      'Delete Routine',
      'Exit'
    ]
    process_main_menu(@@prompt.select('Main Menu:', menu_options))
  end

  def routines_menu_options
    menu_options = [
      { name: 'Set start time', },
      { name: 'Set finish time' },
      { name: 'Move blocks' },
      { name: 'Edit Blocks' },
      { name: 'Delete Blocks' },
      { name: 'Add Blocks' },
      { name: 'Back to main menu' },
      { name: 'Exit' }
    ]
    @@prompt.select('What would you like to do?', menu_options)
  end

  ########## Logic Methods ##########
  def process_main_menu(selection)
    case selection
    when 'Select Routine'
      routines_menu
    when 'Rename Routine'
      rename_routine
    when 'Add Routine'
      add_routine
    when 'Delete Routine'
      delete_routine
    when 'Exit'
      exit_program
    end
  end

  def process_routine_menu(routine, selection)
    case selection
    when 'Set start time'
      routine.modify_routine_times('start')
    when 'Set finish time'
      routine.modify_routine_times('finish')
    when 'Move blocks'
      routine.move_events
    when 'Edit Blocks'
      routine.edit_events
    when 'Delete Blocks'
      routine.delete_events
    when 'Add Blocks'
      routine.populate_events
    when 'Back to main menu'
      save_routines
      # Handled in menu
    when 'Exit'
      exit_program
    end
  end

  def exit_program
    puts 'See you next time!'
    save_routines
    exit
  end

  ########## Mutate Methods ##########
  def add_routine
    name = input_string('Name your routine, or hit enter to cancel:')
    pp name
    return if name.nil?

    @routines << Routine.new(name)
    @routines.last.populate_events
    raise StandardError if @routines.last.events.empty?
  rescue StandardError
    @routines.delete(@routines.last)
    puts 'A routine requires at least one event'
    retry
  end

  def delete_routine
    selection = select_routine
    return if selection == 'Cancel'

    prompt = "Are you sure you wish to delete [#{selection.name}]?"
    return unless user_confirm?(prompt, default: false) do |q|
      q.default false
    end

    @routines.delete(selection)
  end

  def rename_routine
    selection = select_routine
    return if selection == 'Cancel'

    input = input_string('What would you like to rename it? Push Enter to cancel.')
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
      @routines << Routine.new(obj[:name])
      @routines.last.from_json(obj[:events], obj[:total_time], obj[:start_time], obj[:finish_time])
    end
  end
end
