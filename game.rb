# frozen-string-literal: true

# game logic
class Game
  attr_reader :p1, :p2, :turn_count, :board

  NUMBERS_HASH = %w[:one: :two: :three: :four: :five: :six: :seven:].freeze

  # randomize: whether or not to randomize who has the first move
  # contains_ai: whether or not user2 should be considered an ai
  def initialize(user1, user2, randomize: false, contains_ai: false)
    players = [user1, user2]
    players.shuffle! if randomize
    create_players(players, contains_ai)
    @turn_count = 1
    @board = create_board
  end

  def make_move(col, color)
    # assumes the move is legal (column isn't full)
    col_arr = @board[col]
    col_arr[col_arr.index(nil)] = color
    @turn_count += 1
  end

  def stringify_board
    "#{print_number_row}\n#{print_board}"
  end

  def whose_turn
    turn_count.odd? ? @p1 : @p2
  end

  def check_col_full?(col)
    !@board[col].include?(nil)
  end

  def check_win?
    four_in_row? || four_in_col? || four_in_diag?
  end

  def check_board_full?
    @board.reduce(true) do |board_memo, col|
      board_memo && !col.include?(nil)
    end
  end

  private

  def create_players(players, contains_ai)
    @p1 = Player.new(self, :red, players[0])
    p2_class = contains_ai ? AIPlayer : Player
    @p2 = p2_class.new(self, :yellow, players[1])
  end

  def create_board
    board = []
    7.times do
      board.push(Array.new(6, nil)) # empty cells are nil
    end
    board
  end

  def print_number_row
    str = ''
    @board.each_index do |i|
      str += NUMBERS_HASH[i]
    end
    str
  end

  def print_board
    str = ''
    6.times do |num|
      row(num).each do |color|
        str += color.nil? ? ':blue_circle:' : ":#{color}_circle:"
      end
      str += "\n"
    end
    str
  end

  # check if there's any sequence of four in any row on the board
  def four_in_row?
    output = false
    6.times do |num|
      output ||= four_in_ary?(row(num + 1))
    end
    output
  end

  # check if there's any sequence of four in any column on the board
  def four_in_col?
    @board.reduce(false) do |memo, col|
      memo || four_in_ary?(col)
    end
  end

  # check if there's any sequence of four in any diagonal on the board
  def four_in_diag?
    diags = find_up_diags + find_down_diags
    diags.reduce(false) do |memo, diag|
      memo || four_in_ary?(diag)
    end
  end

  # check if there's any sequence of four in an array
  def four_in_ary?(array)
    longest_length = current_length = 1
    array.each_with_index do |el, i|
      next if i.zero?

      !el.nil? && el == array[i - 1] ? current_length += 1 : current_length = 1
      longest_length = current_length if current_length > longest_length
    end
    longest_length >= 4
  end

  def find_up_diags
    board = Marshal.load(Marshal.dump(@board)) # deep copy
    # shift each column down proportionally to make the diagonals line up
    board.each_with_index do |col, i|
      (6 - i).times { col.unshift(false) }
      i.times { col.push(false) }
    end
    make_diags(board)
  end

  def find_down_diags
    board = Marshal.load(Marshal.dump(@board)) # deep copy
    # shift each column up proportionally to make the diagonals line up
    board.each_with_index do |col, i|
      i.times { col.unshift(false) }
      (6 - i).times { col.push(false) }
    end
    make_diags(board)
  end

  def make_diags(board)
    diags = []
    board[0].length.times do |num|
      diag = row(num, board)
      diag.delete(false)
      diags.push(diag)
    end
    diags
  end

  # rows counted top to bottom, starts at 0
  def row(num, board = @board)
    index = board[0].length - 1 - num
    row_arr = []
    board.each do |col|
      row_arr.push(col[index])
    end
    row_arr
  end
end
