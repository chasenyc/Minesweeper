class Square
  attr_reader :bomb, :hidden, :flagged, :value
  alias_method :bomb?, :bomb

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

  def initialize(board_size = 9, bomb_percent = DEFAULT_BOMB_PERCENT)
    @grid = []
    populate(board_size, bomb_percent)
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    @grid[x][y] = value
  end

  def populate(board_size, bomb_percent)
    @grid = (0...board_size).map do |row|
      (0...board_size).map do |col|
        rand < bomb_percent ? Square.new(true) : Square.new(false)
      end
    end
    set_values
  end

  def set_values
    (0...grid.length).each do |row|
      (0...grid.length).each do |col|
        pos = [row, col]
        if self[pos].bomb?
          self[pos].set_value("B")
        else
          self[pos].set_value(neighbor_bomb_count(pos))
        end
      end
    end
  end

  def neighbor_bomb_count(pos)
    get_neighbors(pos).count(&:bomb?)
  end

  def get_neighbors(pos)
    OFFSETS.map do |offset|
      add_squares(offset, pos)
    end.select { |square| valid_pos?(square) }.map { |pos| self[pos] }
  end

  def add_squares(square1, square2)
    [square1.first + square2.first, square1.last + square2.last]
  end

  def valid_pos?(pos)
    pos.all? { |num| num.between?(0, grid.length - 1) }
  end

  def to_s
    grid.map do |row|
      row.map(&:to_s).join(" ")
    end.join("\n")
  end

  def render
    system("clear")
    puts to_s
  end

end

class Game
  attr_reader :board
  DIFFICULTIES = (1..5).reduce({}) { |accum,level| accum.merge({level => (level * 0.1).round(2) }) }

  def initialize(board_size = 9, difficulty = 5)
    @board = Board.new(board_size, DIFFICULTIES[difficulty])
  end
  
end
