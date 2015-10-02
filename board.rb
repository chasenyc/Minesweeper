require 'forwardable'

class Board
  extend Forwardable
  include Enumerable

  OFFSETS = (-1..1).to_a.repeated_permutation(2).to_a.delete_if { |a| a == [0, 0] }

  attr_reader :grid
  def_delegators :@grid, :length, :each

  def initialize(board_size, bomb_percent)
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
    (0...length).each do |row|
      (0...length).each do |col|
        pos = [row, col]

        if self[pos].bomb?
          self[pos].value = "B"
        else
          self[pos].value = neighbor_bomb_count(pos)
        end
      end
    end
  end

  def neighbor_bomb_count(pos)
    get_neighbors(pos).count(&:bomb?)
  end

  def get_neighbors(pos)
    get_neighboring_positions(pos).map { |pos| self[pos] }
  end

  def get_neighboring_positions(pos)
    OFFSETS.map { |offset| add_squares(offset, pos) }.select { |pos| valid_pos?(pos) }
  end

  def hidden_neighboring_positions(pos)
    get_neighboring_positions(pos).select { |pos| self[pos].hidden? }
  end

  def explode_pos!(pos)
    hidden_neighboring_positions(pos).each do |neighbor_pos|
      next if self[neighbor_pos].flagged?
      self[neighbor_pos].reveal!
      explode_pos!(neighbor_pos) if self[neighbor_pos].value == 0
    end
  end

  def add_squares(square1, square2)
    [square1.first + square2.first, square1.last + square2.last]
  end

  def valid_pos?(pos)
    pos.all? { |num| num.between?(0, length - 1) }
  end

  def to_s
    " " + (0...length).map(&:to_s).join(" ") + "\n" +
    map.with_index do |row, row_idx|
      "#{row_idx}" + row.map(&:to_s).join(" ").colorize(background: Square::BACKGROUND_COLOR)
    end.join("\n")
  end

  def render
    system("clear")
    puts to_s
  end
end
