require 'json'
require 'tty-prompt'
require 'colorize'
require 'terminal-table'
require 'artii'

require_relative './lib/argv'
require_relative './lib/mixins'
require_relative './lib/application'
require_relative './lib/routine'

if ARGV.empty?
  routinely = Menu.new
  routinely.run
else
  argv = ArgvMenu.new
  argv.interpret
end
