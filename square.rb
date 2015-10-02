require 'colorize'

class Square
  BACKGROUND_COLOR = :light_white

  COLORS = {
    '0' => :white,
    '1' => :light_blue,
    '2' => :green,
    '3' => :light_red,
    '4' => :blue,
    '5' => :red,
    '6' => :cyan,
    '7' => :magenta,
    '8' => :light_black,
    'F' => :red,
    'B' => :black
  }

  SPECIAL_CHARS = {
    '0' => "\u25fd",
    'F' => "\u2691",
    'B' => "\u2622",
  }

  IMAGES = (('0'..'9').to_a + ['F', 'B']).reduce({}) do |acc, letter|
    str = SPECIAL_CHARS.has_key?(letter) ? SPECIAL_CHARS[letter] : letter
    acc.merge({letter => str.colorize(COLORS[letter])})
  end

  attr_reader :bomb, :hidden, :flagged, :value
  alias_method :bomb?, :bomb
  alias_method :hidden?, :hidden
  alias_method :flagged?, :flagged

  def initialize(bomb = false)
    @bomb = bomb
    @hidden = true
    @flagged = false
  end

  def toggle_flag!
    @flagged = !flagged
  end

  def reveal!
    @hidden = false
    bomb
  end

  def revealed?
    !hidden
  end

  def to_s
    if hidden
      flagged ? IMAGES["F"] : " "
    else
      IMAGES[value.to_s]
    end
  end

  def set_value(value)
    @value = value
  end
end
