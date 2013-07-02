require_relative 'fen_move'

class DbRef
  attr_reader :name

  def initialize(name)
    @name = name
    @fen_moves = []
  end

  def add_fen_move(fen_move)
    @fen_moves << fen_move
  end

  def getPercentage(fen_move)
    coincidences = 0
    points = 0
    @fen_moves.each do |fen|
      if (fen.fen_move.eql? fen_move)
        coincidences += 1
        if (fen.winner_side.eql? 'd')
          points += 0.5
        elsif (fen.winner_side.eql? 'w')
          points += 1
        end
      end
    end
    if coincidences == 0
      return -1, coincidences
    end
    return points/coincidences*100, coincidences
  end

end