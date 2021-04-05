require 'json'
require 'tty-prompt'

require_relative './lib/application'
require_relative './lib/routine'

routinely = Menu.new
routinely.run
