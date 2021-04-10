module Mixins
  def asciify(string)
    ascii = Artii::Base.new
    ascii.asciify(string)
  end

    # Prompt for user confirmation on a prompt, optional variable allows switching of default
    def user_confirm?(prompt, default: true)
      @@prompt.yes?(prompt) do |q|
        q.default default
      end
    end

  @@prompt = TTY::Prompt.new

  @@colors = [
    :green,
    :light_green,
    :light_yellow,
    :blue,
    :light_blue,
    :magenta,
    :light_magenta,
    :cyan,
    :light_cyan
  ]
end
