class Game
  attr_accessor :white, :black, :annotator, :white_deviation, :black_deviation,
    :event, :site, :date, :round, :result, :enddate, :whitestddeviation, :whiteperfectmoves,
    :whiteblunders, :whiteavgerror, :blackavgerror, :blackstddeviation, :blackperfectmoves,
    :blackblunders
  attr_reader :moves

  OBLIGATORY_TAGS = ['Event', 'Site', 'Date', 'Round', 'White', 'Black', 'Result']
  AVAILABLE_TAGS = OBLIGATORY_TAGS + ['Annotator', 'EndDate', 'WhiteAvgError',
                                      'WhiteStdDeviation', 'WhitePerfectMoves', 'WhiteBlunders',
                                      'BlackAvgError', 'BlackStdDeviation', 'BlackPerfectMoves', 'BlackBlunders']

  def initialize
    @moves = []
  end

  def tie_threshold
  end

  def blunder_threshold
  end

  def add_move move
    @black_moves = nil unless move.white?
    @white_moves = nil unless move.black?
    @moves << move
  end

  def set_tag(tag, value)
    if AVAILABLE_TAGS.include?(tag)
      send "#{tag.downcase}=", value[1..-2] # Remove "
    end
  end

  def white_avg_deviation
    avg_deviation white_moves
  end

  def black_avg_deviation
    avg_deviation black_moves
  end

  def white_standard_deviation
    standard_deviation white_moves
  end

  def black_standard_deviation
    standard_deviation black_moves
  end

  def white_perfect_moves
    perfect_moves white_moves
  end

  def black_perfect_moves
    perfect_moves black_moves
  end

  def white_blunders tie_threshold, blunder_threshold
    blunders white_moves, tie_threshold, blunder_threshold
  end

  def black_blunders tie_threshold, blunder_threshold
    blunders black_moves, tie_threshold, blunder_threshold
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

  def get_info_for player_name
    result = {}
    if @white == player_name
      result[:avg_err] = @whiteavgerror.to_f
      result[:std_dev] = @whitestddeviation.to_f
      result[:perfect] = @whiteperfectmoves.to_f
      result[:blunders] = @whiteblunders.to_f
    elsif @black == player_name
      result[:avg_err] = @blackavgerror.to_f
      result[:std_dev] = @blackstddeviation.to_f
      result[:perfect] = @blackperfectmoves.to_f
      result[:blunders] = @blackblunders.to_f
    end
    result
  end

  private
  def avg_deviation(moves)
    moves.collect(&:deviation).inject(:+) / moves.size.to_f
  end

  def standard_deviation moves
    avg = avg_deviation moves
    sigma = moves.map { |m| m.standard_deviation(avg) }.inject(:+) / (moves.size - 1).to_f
    Math.sqrt sigma
  end

  def perfect_moves moves
    moves.select { |m| m.deviation == 0 }.size / moves.size.to_f
  end

  def blunders moves, tie_threshold, blunder_threshold
    moves.select { |m| m.blunder?(tie_threshold, blunder_threshold) }.size / moves.size.to_f
  end
end
