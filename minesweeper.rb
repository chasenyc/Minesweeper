class Square
  attr_reader :bomb, :hidden, :flagged

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
end
