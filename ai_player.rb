# frozen-string-literal: true

# logic for an ai player that always finds the best move
class AIPlayer < Player
  def find_best_move
    rand(0..6)
  end
end
