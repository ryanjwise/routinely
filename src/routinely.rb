require 'json'
require 'tty-prompt'
require 'colorize'
require 'terminal-table'

require_relative './lib/application'
require_relative './lib/routine'

routinely = Menu.new
routinely.run
