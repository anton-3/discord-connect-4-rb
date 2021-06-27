# frozen-string-literal: true

#
# TODO:
# improve heuristic function
# more optimization
#

# logic for an ai player that always finds the best move
# eval table borrowed from https://softwareengineering.stackexchange.com/questions/263514/why-does-this-evaluation-function-work-in-a-connect-four-game-in-java
class AIPlayer < Player
  # 1-3 is fast, 5 is ~5 seconds per move
  CUTOFF_DEPTH = 5
  EVAL_TABLE = [
    [3, 4, 5, 7, 5, 4, 3],
    [4, 6, 8, 10, 8, 6, 4],
    [5, 8, 11, 13, 11, 8, 5],
    [5, 8, 11, 13, 11, 8, 5],
    [4, 6, 8, 10, 8, 6, 4],
    [3, 4, 5, 7, 5, 4, 3]
  ].freeze
  LOG_MOVES = true

  def initialize(*)
    super
    @board = @game.board
  end

  # AI level 1
  # makes random moves
  def find_random_move
    @board.legal_moves.sample
  end

  # AI level 2
  # takes and blocks immediate wins, otherwise makes random moves
  def find_decent_move
    return 3 if @board.turn_count == 1

    if win_for?(@board, @value)
      find_winning_move(@board)
    elsif win_for?(@board, -@value)
      find_blocking_move(@board)
    else
      find_random_move
    end
  end

  # AI level 3
  # recursively finds the best move using the minimax algorithm
  def find_best_move
    return 3 if @board.turn_count == 1

    moves = {}

    @board.legal_moves.each do |move|
      copy = Marshal.load(Marshal.dump(@board))
      copy.make_move(move, @value)
      score = -minimax(copy, -@value)
      moves[move] = score
    end

    best_moves = moves.select { |_move, score| score == moves.values.max }.keys
    move = best_moves.sample # if there are multiple best moves with the same value, choose a random one
    log(moves, move) if LOG_MOVES
    move
  end

  private

  # board: the board scored by the minimax function
  # p_value: the value of the player that's being scored for, either 1 or -1
  # a greater score means it's better for that player
  # depth: the recursive depth of the function
  # alpha and beta: alpha beta pruning http://blog.gamesolver.org/solving-connect-four/04-alphabeta/
  def minimax(board, p_value, depth = 0, alpha = -10000, beta = 10000)
    return 0 if board.full?
    return -1000 + depth if board.win?
    return heuristic(board, p_value) if depth == CUTOFF_DEPTH

    board.legal_moves.each do |move|
      copy = Marshal.load(Marshal.dump(board))
      copy.make_move(move, p_value)
      score = -minimax(copy, -p_value, depth + 1, -beta, -alpha)
      return score if score >= beta

      alpha = score if score > alpha
    end

    alpha
  end

  # returns static evaluation of a board position
  # creates a score based on the positions of the pieces
  def heuristic(board, p_value)
    score = 0
    board.contents.each_with_index do |col, col_idx|
      col.each_with_index do |value, row_idx|
        next if value.zero?

        eval_value = EVAL_TABLE[row_idx][col_idx]
        value == p_value ? score += eval_value : score -= eval_value
      end
    end
    score
  end

  def win_for?(board, value)
    board.legal_moves.reduce(false) do |memo, move|
      memo || winning_move?(board, move, value)
    end
  end

  def winning_move?(board, move, value)
    copy = Marshal.load(Marshal.dump(board))
    copy.make_move(move, value)
    copy.win?
  end

  # assumes there's a winning move for self
  def find_winning_move(board)
    board.legal_moves.each do |move|
      return move if winning_move?(board, move, @value)
    end
  end

  # assumes there's a winning move for opponent
  def find_blocking_move(board)
    board.legal_moves.each do |move|
      return move if winning_move?(board, move, -@value)
    end
  end

  def log(moves, move)
    puts "Turn: #{@board.turn_count}, name: #{@name}, color: #{@color}"
    puts Time.new.strftime('%H:%M:%S')
    p moves
    puts move
    puts
  end
end
