require 'colorize'

class Square
  BACKGROUND_COLOR = :light_white

  COLORS = {
    '0' => BACKGROUND_COLOR,
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
    '0' => ' ',
    'F' => "\u2691",
    'B' => "\u2622",
  }
  IMAGES = (('0'..'9').to_a + ['F', 'B']).reduce({}) do |acc, letter|
    str = SPECIAL_CHARS.has_key?(letter) ? SPECIAL_CHARS[letter] : letter
    acc.merge({letter => str.colorize(COLORS[letter])})
  end

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
    puts to_s.colorize(background: Square::BACKGROUND_COLOR)
  end

end

class Game
  attr_reader :board, :win
  alias_method :win?, :win
  DIFFICULTIES = (1..5).reduce({}) { |accum,level| accum.merge({level => (level * 0.1).round(2) }) }
  POS_REGEXP = Regexp.new(/^\d,\s*\d$/)

  def initialize(board_size = 9, difficulty = 5)
    @board = Board.new(board_size, DIFFICULTIES[difficulty])
    @game_over = false
    @win = false
  end

  def play
    while !game_over?
      board.render
      pos, click = get_input
      make_move(pos, click)
    end

    puts game_over_message
  end

  def get_input
    puts "Enter position, in form: row, column"
    print "> "
    pos_str = gets.chomp
  end

  def valid_pos_str?(pos_str)
    !(pos_str =~ POS_REGEXP).nil?
  end

  def game_over?
    @game_over
  end

  def won_game?
    all_non_bomb_positions.all? { |pos| board[pos].revealed? }
  end

  def game_over_message
    return "" unless game_over?
    win? ? "YOU WIN!!" : "TRY AGAIN"
  end

  def make_move(pos, click = 'left')
    click == 'right' ? right_click(pos) : left_click(pos)
  end

  def right_click(pos)
    board[pos].toggle_flag!
  end

  def left_click(pos)
    if board[pos].reveal!
      lose_game
    elsif won_game?
      win_game
    end
  end

  def lose_game
    @game_over = true
    reveal_all_bombs!
  end

  def win_game
    @game_over = true
    @win = true
  end

  def all_positions
    (0..9).to_a.repeated_permutation(2).to_a
  end

  def all_non_bomb_positions
    all_positions.reject { |pos| board[pos].bomb? }
  end

  def all_bomb_positions
    all_positions.select { |pos| board[pos].bomb? }
  end

  def reveal_all_bombs!
    all_bomb_positions.each { |pos| board[pos].reveal! }
  end

end
