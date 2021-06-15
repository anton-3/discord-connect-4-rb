# frozen-string-literal: true

# player logic
class Player
  attr_reader :user, :game, :color, :name

  def initialize(user, game, color)
    @user = user
    @game = game
    @color = color
    @name = user.display_name
  end

  def make_move(col)
    @game.make_move(col, @color)
  end
end
