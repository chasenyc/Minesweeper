class Square
  attr_reader :bomb, :hidden, :flagged

  def initialize(bomb = false)
    @bomb = bomb
    @hidden = true
    @flagged = false
  end
end
