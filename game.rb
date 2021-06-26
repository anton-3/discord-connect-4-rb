# frozen-string-literal: true

# game logic
class Game
  attr_reader :p1, :p2, :board

  NUMBERS_HASH = %w[:one: :two: :three: :four: :five: :six: :seven:].freeze

  # randomize: whether or not to randomize who has the first move
  # which_ai: which users should be considered ai
  def initialize(user1, user2, randomize: false, which_ai: [false, false])
    players = [user1, user2]
    create_players(players, which_ai, randomize)
    @board = Board.new
  end

  def make_move(col, color)
    @board.make_move(col, color)
  end

  def to_s
    "#{print_num_row}\n#{@board}"
  end

  def whose_turn
    # @p1 always goes first
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

  def create_players(players, contains_ai, randomize)
    order = [0, 1]
    order.shuffle! if randomize
    p1_class = contains_ai[order[0]] ? AIPlayer : Player
    p2_class = contains_ai[order[1]] ? AIPlayer : Player
    @p1 = p1_class.new self, :red, players[order[0]]
    @p2 = p2_class.new self, :yellow, players[order[1]]
  end
end
