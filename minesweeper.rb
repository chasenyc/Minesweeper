class Square
  attr_reader :bomb, :hidden, :flagged, :value

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

  def to_s
    if hidden
      flagged ? "F" : "?"
    else
      value.to_s
    end
  end

  def set_value(value)
    @value = value
  end

end

class Board
  attr_reader :grid
  DEFAULT_BOMB_PERCENT = 0.3

  def initialize()
    @grid = []
  end

  def populate(board_size = 9, bomb_percent = DEFAULT_BOMB_PERCENT)
    @grid = (0...board_size).map do |row|
      (0...board_size).map do |col|
        rand < bomb_percent ? Square.new(true) : Square.new(false)
      end
    end
  end

  def to_s
    p grid.map do |row|
      row.map(&:to_s).join(" ")
    end.join("\n")
  end

end
