class FenMove
  attr_reader :fen_move, :game_number, :winner_side

  def initialize(fen_move,game_number,winner_side)
    @fen_move = fen_move
    @game_number = game_number
    @winner_side = winner_side
  end

end