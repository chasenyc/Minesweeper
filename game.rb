require_relative 'board.rb'
require_relative 'square.rb'
require 'colorize'

class Game
  DIFFICULTIES = (1..5).reduce({}) { |accum,level| accum.merge({level => (level * 0.05).round(2) }) }
  DEFAULT_DIFFICULTY = 2
  DEFAULT_BOARD_SIZE = 9
  POS_REGEXP = Regexp.new(/^\d,\s*\d$/)

  attr_reader :board, :win
  alias_method :win?, :win

  def initialize(board_size = DEFAULT_BOARD_SIZE, difficulty = DEFAULT_DIFFICULTY)
    @board = Board.new(board_size, DIFFICULTIES[difficulty])
    @game_over = false
    @win = false
  end

  def play
    while !game_over?
      board.render
      make_move(get_input)
    end

    board.render
    puts game_over_message
  end

  def get_input
    [get_position, get_click]
  end

  def get_position
    pos_str = nil

    until (pos = validate_position(pos_str))
      puts "Invalid input." if (pos == false && !pos_str.nil?)
      puts "Enter position, in form: row, column"
      print "> "
      pos_str = gets.chomp
    end

    pos
  end

  def get_click
    click = nil

    until valid_click?(click)
      print "(F)lag or (R)eveal?: "
      click = gets.chomp
    end
    
    parse_click(click)
  end

  def parse_click(click)
    case click.downcase
    when "f"
      "right"
    when "r"
      "left"
    else
      raise "Invalid click"
    end
  end

  def valid_click?(click)
    click == "F" || click == "f" || click == "R" || click == "r"
  end

  def validate_position(pos_str)
    return false unless valid_pos_str?(pos_str)
    pos = parse_pos(pos_str)
    in_bounds?(pos) ? pos : false
  end

  def valid_pos_str?(pos_str)
    pos_str.is_a?(String) && !(pos_str =~ POS_REGEXP).nil?
  end

  def in_bounds?(pos)
    pos.all? { |num| num.between?(0, board.length - 1) }
  end

  def parse_pos(pos_str)
    pos_str.split(",").map(&:strip).map(&:to_i)
  end

  def game_over?
    @game_over
  end

  def won_game?
    all_non_bomb_positions.all? { |pos| board[pos].revealed? } && !game_over?
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
    return if board[pos].flagged?

    if board[pos].reveal!
      lose_game
    elsif board[pos].value == 0
      board.explode_pos!(pos)
    end

    if won_game?
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
    (0...9).to_a.repeated_permutation(2).to_a
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


if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
