class Game
  attr_accessor :white, :black, :annotator, :white_deviation, :black_deviation,
    :event, :site, :date, :round, :result

  OBLIGATORY_TAGS = ['Event', 'Site', 'Date', 'Round', 'White', 'Black', 'Result']
  AVAILABLE_TAGS = OBLIGATORY_TAGS + ['Annotator']

  def initialize
    @moves = []
  end

  def add_move move
    @black_moves = nil unless move.white?
    @white_moves = nil unless move.black?
    @moves << move
  end

  def set_tag(tag, value)
    if AVAILABLE_TAGS.include?(tag)
      send "#{tag.downcase}=", value
    end
  end

  def white_avg_deviation
    white_moves.collect(&:deviation).inject(:+) / white_moves.size
  end

  def black_avg_deviation
    black_moves.collect(&:deviation).inject(:+) / black_moves.size
  end

  def black_moves
    @black_moves ||= @moves.select{ |m| m.black? }
  end

  def white_moves
    @white_moves ||= @moves.select{ |m| m.white? }
  end

  def to_s
    AVAILABLE_TAGS.map { |tag| "#{tag} #{send tag.downcase}" }.join("\n") + "\n" +
      @moves.collect(&:to_s).join("\n") + @result.to_s
  end

  def player_ratings
    "White - #{@white} - #{'%.2f' % white_avg_deviation}\n" +
    "Black - #{@black} - #{'%.2f' % black_avg_deviation}\n"
  end
end
