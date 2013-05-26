class Game < ActiveRecord::Base
  attr_accessible :annotator, :black_avg_error, :black_blunder_rate, :black_id, :black_perfect_rate, :black_std_deviation,
    :end_date, :result, :round, :site_id, :start_date, :status, :tournament_id, :white_avg_error, :white_blunder_rate,
    :white_id, :white_perfect_rate, :white_std_deviation, :progress, :tie_threshold, :blunder_threshold

  OBLIGATORY_TAGS = {'Event' => :tournament, 'Site' => :site, 'Date' => :start_date, 'Round' => :round,
                     'White' => :white, 'Black' => :black, 'Result' => :result}
  OPTIONAL_TAGS = {'Annotator' => :annotator, 'EndDate' => :end_date, 'WhiteAvgError' => :white_avg_error,
                                      'WhiteStdDeviation' => :white_std_deviation, 'WhitePerfectMoves' => :white_perfect_rate,
                                      'WhiteBlunders' => :white_blunder_rate,'BlackAvgError' => :black_avg_error,
                                      'BlackStdDeviation' => :black_std_deviation, 'BlackPerfectMoves' => :black_perfect_rate,
                                      'BlackBlunders' => :black_blunder_rate}
  AVAILABLE_TAGS = OBLIGATORY_TAGS.merge OPTIONAL_TAGS

  has_many :moves, dependent: :destroy
  belongs_to :tournament
  belongs_to :site
  belongs_to :white, class_name: 'Player'
  belongs_to :black, class_name: 'Player'

  def add_move(move)
    moves << move
  end

  def set_tag(tag, value)
    if AVAILABLE_TAGS.keys.include?(tag)
      case AVAILABLE_TAGS[tag]
      when :tournament
        self.tournament = Tournament.find_or_create_by_name(value[1..-2])
      when :site
        self.site = Site.find_or_create_by_name(value[1..-2])
      when :black
        self.black = Player.find_or_create_by_name(value[1..-2])
      when :white
        self.white = Player.find_or_create_by_name(value[1..-2])
      else
        public_send "#{AVAILABLE_TAGS[tag]}=", value[1..-2] # Remove "
      end
    end
  end

  def white_avg_error
    white_avg_error ||= avg_error(moves.white)
  end

  def black_avg_error
    black_avg_error ||= avg_error(moves.black)
  end

  def white_std_deviation
    white_std_deviation ||= standard_deviation(moves.white)
  end

  def black_std_deviation
    black_std_deviation ||= standard_deviation(moves.black)
  end

  def white_perfect_rate
    white_perfect_rate ||= perfect_rate(moves.white)
  end

  def black_perfect_rate
    black_perfect_rate ||= perfect_rate(moves.black)
  end

  def white_blunder_rate
    white_blunder_rate ||= blunder_rate(moves.white, tie_threshold, blunder_threshold)
  end

  def black_blunder_rate
    black_blunder_rate ||= blunder_rate(moves.black, tie_threshold, blunder_threshold)
  end

  def player_ratings
    "White - #{@white} - #{'%.2f' % self.white_avg_error}\n" +
    "Black - #{@black} - #{'%.2f' % self.black_avg_error}\n"
  end

  def get_info_for(player_name)
    result = {}
    if white == player_name
      result[:avg_err] = white_avg_error
      result[:std_dev] = white_std_deviation
      result[:perfect] = white_perfect_rate
      result[:blunders] = white_blunder_rate
    elsif black == player_name
      result[:avg_err] = black_avg_error
      result[:std_dev] = black_std_deviation
      result[:perfect] = black_perfect_rate
      result[:blunders] = black_blunder_rate
    end
    result
  end

  private
  def avg_error(moves)
    (moves.collect(&:deviation).inject(:+) || 0) / moves.size.to_f
  end

  def standard_deviation(moves)
    avg = avg_error moves
    sigma = (moves.map { |m| m.standard_deviation(avg) }.inject(:+) || 0) / (moves.size - 1).to_f
    Math.sqrt sigma
  end

  def perfect_rate(moves)
    moves.select { |m| m.deviation == 0 }.size / moves.size.to_f
  end

  def blunder_rate(moves, tie_threshold, blunder_threshold)
    moves.select { |m| m.blunder?(tie_threshold, blunder_threshold) }.size / moves.size.to_f
  end
end
