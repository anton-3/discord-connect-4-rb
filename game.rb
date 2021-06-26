# frozen-string-literal: true

# game logic
class Game
  attr_reader :p1, :p2, :board

  NUMBERS_HASH = %w[:one: :two: :three: :four: :five: :six: :seven:].freeze

  # randomize: whether or not to randomize who has the first move
  # contains_ai: whether or not user2 should be considered an ai
  def initialize(user1, user2, randomize: false, contains_ai: false)
    players = [user1, user2]
    players.shuffle! if randomize
    create_players(players, contains_ai)
    @board = Board.new
  end

  def make_move(col, color)
    @board.make_move(col, color)
  end

  def to_s
    "#{print_num_row}\n#{@board}"
  end

  def whose_turn
    @board.turn_count.odd? ? @p1 : @p2
  end

  def check_win?
    @board.check_win?
  end

  def check_col_full?(col)
    @board.check_col_full?(col)
  end

  def check_board_full?
    @board.check_full?
  end

  private

  def print_num_row
    str = ''
    7.times do |num|
      str += NUMBERS_HASH[num]
    end
    str
  end

  def create_players(players, contains_ai)
    @p1 = Player.new(self, :red, players[0])
    p2_class = contains_ai ? AIPlayer : Player
    @p2 = p2_class.new(self, :yellow, players[1])
  end
end
