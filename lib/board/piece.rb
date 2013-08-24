module Board
  class Piece
    attr_accessor :position, :board, :side

    def initialize(board, side, position)
      @board = board
      @side = side
      @position = position
    end

    def can_move_to? position
      raise 'Implement me in subclass'
    end

    def move_to position
      raise NoPositionError.new unless @position && position
      from = @position.to_s
      @board.set_piece(nil, @position.file_to_i, rank) # empty from coords
      @board.eliminate @board.piece_at(position) # eliminate piece if there was one
      @board.en_passant = nil

      @position = position
      @board.set_piece(self, position.file_to_i, rank) # place piece in new coords

      from # return algebraic old source
    end

    def on_rank?(rank)
      raise NoPositionError.new unless @position
      @position.on_rank? rank
    end

    def on_file?(file)
      raise NoPositionError.new unless @position
      @position.on_file? file
    end

    def file_to_i
      raise NoPositionError.new unless @position
      @position.file_to_i
    end

    def rank
      raise NoPositionError.new unless @position
      @position.rank
    end

    def to_s
      "#{self.class} at #{@position}"
    end
  end

  class NoPositionError < StandardError; end
end
