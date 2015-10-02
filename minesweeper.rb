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
  OFFSETS = (-1..1).to_a.repeated_permutation(2).to_a.delete_if { |a| a == [0, 0] }

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

  def set_values
    grid.each do |row|
      row.each do |square|

      end
    end
  end

  def get_neighbors(pos)
    OFFSETS.map { |offset| add_squares(offset, pos) }
  end

  def add_squares(square1, square2)
    [square1.first + square2.first, square1.last + square2.last]
  end

  def valid_pos?(pos)
    pos.all? { |num| num.between?(0, grid.length - 1) }
  end

  def to_s
    p grid.map do |row|
      row.map(&:to_s).join(" ")
    end.join("\n")
  end

end
