class ArgvMenu
  def interpret
    first, *other = ARGV
    ARGV.clear
    case first
    when '-h', '--help'
      help_message
    when '-add'
      args_add
    when '-view'
      args_view(other)
    end
  end

  def args_add
    routinely = Menu.new
    routinely.add_routine
    routinely.save_routines
  end

  def args_view(other)
    routinely = Menu.new
    routinely.print_routines
    routinely.routines_menu if other[0] == '-r' || other[0] == '-routine'
    return if other[0].empty?

    match = nil
    routinely.routines.each { |routine| match = routine if routine.name == other[0] }
    match.print_events unless match.nil?
  end

  def help_message
    puts
    puts 'Routinely aims to provide a method for users to quickly create and reorder a sequence of events or tasks.'
    puts "To get started, load the application and select 'add routine'."
    puts
    puts 'Once a routine has been established it is populated with a series of events, to manipulate these events '\
         'select the routine.'
    puts 'Once within a routine, events can be added or deleted, edited and reordered.'
    puts 'A start or end time for the running of the entire routine can also be input with the respective menu options.'
    puts
    puts 'To save, either return to the main menu, or select Exit.'
    puts 'N.B. If the application is quit in any other way, progress will not be saved.'
    puts
    args_usage
  end

  def args_usage
    puts 'ruby routinely.rb [options] [arg_name]'
    puts
    puts 'Options:'
    puts "\t-add\t\t\tJumps straight to the add new routine screen, then saves on completion and exits"
    puts "\t-view\t\t\tPrints available routines"
    puts "\t-view [-r]\t\tPrints available routines, then allows user to select an option an jump straight to edit"
    puts "\t-view [routine_name]\tPrints the input routine and exits"
  end
end
