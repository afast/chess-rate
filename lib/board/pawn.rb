require 'pry'
module Board
  class Pawn < Piece
    def can_move_to? position
      return InvalidPositionError.new unless position.valid?
      rank_dis = @position.rank_distance(position) # rank distance
      file_dis = @position.file_distance(position) # file distance

      can_move = (position.rank - @position.rank) == (side == :black ? -1 : 1)
      can_move = can_move && rank_dis == 1 && (file_dis == 0 && @board.square_empty?(position) ||
                                               file_dis == 1 && (!@board.square_empty?(position) || @board.en_passant.to_s == position.to_s)) # can move forward
      can_move = can_move || rank_dis == 2 && file_dis == 0 && # en passant
        @board.empty_ranks_between?(@position, position) && (position.rank - @position.rank) == (side == :black ? -2 : 2)

      can_move
    end

    def move_to position
      raise NoPositionError.new unless @position && position
      from = @position.to_s
      @board.set_piece(nil, @position.file_to_i, rank) # empty from coords

      if position.to_s == @board.en_passant.to_s
        pos = Position.new(position.file, position.rank + (side == :black ? 1 : -1))
        @board.eliminate @board.piece_at(pos) # eliminate piece if there was one
        @board.set_piece(nil, pos.file_to_i, pos.rank) # empty from coords
      else
        @board.eliminate @board.piece_at(position) # eliminate piece if there was one
      end

      if @position.rank_distance(position) == 2
        @board.en_passant = Position.new(position.file, position.rank + (side == :black ? 1 : -1))
      else
        @board.en_passant = nil
      end

      @position = position
      @board.set_piece(self, position.file_to_i, rank) # place piece in new coords

      from # return algebraic old source
    end

    def board_print
      side == :black ? 'p' : 'P'
    end
  end
  class InvalidPositionError < StandardError; end
end
