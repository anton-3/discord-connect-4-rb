# frozen-string-literal: true

# logic for all connect 4 players
class Player
  attr_reader :game, :color, :user, :name

  def initialize(game, color, user)
    @game = game
    @color = color
    @user = user
    @name = user.display_name
  end

  def make_move(col)
    @game.make_move(col, @color)
  end
end
