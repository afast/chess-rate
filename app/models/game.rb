class Game < ActiveRecord::Base
  include Background

  attr_accessible :annotator, :black_avg_error, :black_blunder_rate, :black_id, :black_perfect_rate, :black_std_deviation,
    :end_date, :result, :round, :site_id, :start_date, :status, :tournament_id, :white_avg_error, :white_blunder_rate,
    :white_id, :white_perfect_rate, :white_std_deviation, :progress, :tie_threshold, :blunder_threshold,
    :player_out_db_ref, :move_out_db_ref, :value_out_db_ref, :best_value_out_db_ref, :deviation_out_db_ref,
    :white_elo, :black_elo
  attr_accessor :en_passant

  OBLIGATORY_TAGS = {'Event' => :tournament, 'Site' => :site, 'Date' => :start_date, 'Round' => :round,
                     'White' => :white, 'Black' => :black, 'Result' => :result}
  OPTIONAL_TAGS = {'Annotator' => :annotator, 'EndDate' => :end_date, 'WhiteAvgError' => :white_avg_error,
                   'WhiteElo' => :white_elo, 'BlackElo' => :black_elo,
                   'WhiteStdDeviation' => :white_std_deviation, 'WhitePerfectMoves' => :white_perfect_rate,
                   'WhiteBlunders' => :white_blunder_rate,'BlackAvgError' => :black_avg_error,
                   'BlackStdDeviation' => :black_std_deviation, 'BlackPerfectMoves' => :black_perfect_rate,
                   'BlackBlunders' => :black_blunder_rate}
  AVAILABLE_TAGS = OBLIGATORY_TAGS.merge OPTIONAL_TAGS
  STATUS = {not_processed: 0, processing: 1, processed: 2}

  has_many :moves, dependent: :destroy
  belongs_to :tournament
  belongs_to :site
  belongs_to :white, class_name: 'Player'
  belongs_to :black, class_name: 'Player'
  belongs_to :pgn_file

  def add_move(move)
    @cache_moves = [] if @cache_moves.nil?
    @cache_moves << move
  end

  def save_moves
    return if @cache_moves.nil?
    transaction do
      @cache_moves.each do |m|
        m.update_attributes game: self
      end
    end
  end

  def name
    "#{wite.name}-#{black.name}.pgn"
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
        #puts "#{AVAILABLE_TAGS[tag]}=#{value[1..-2]}"
        public_send "#{AVAILABLE_TAGS[tag]}=", value[1..-2]
      end
    end
  end

  def get_tag(tag)
    if AVAILABLE_TAGS.keys.include?(tag)
      case AVAILABLE_TAGS[tag]
      when :tournament
        self.tournament.try(:name)
      when :site
        self.site.try(:name)
      when :black
        self.black.try(:name)
      when :white
        self.white.try(:name)
      else
        public_send AVAILABLE_TAGS[tag]
      end
    end
  end

  def white_avg_error
    white_avg_error ||= avg_error(moves.white)
  end

  def black_avg_error
    black_avg_error ||= avg_error(moves.black)
  end

  def total_avg_error
    avg_error(moves)
  end

  def total_perfect_rate
    perfect_rate(moves)
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
    result[:name] = tournament.try :name
    result[:start_date] = start_date
    result[:end_date] = end_date
    if white.name == player_name
      result[:avg_err] = white_avg_error
      result[:std_dev] = white_std_deviation
      result[:perfect] = white_perfect_rate
      result[:blunders] = white_blunder_rate
      result[:color] = 'color.white'
      result[:elo] = white_elo
      result[:rival] = black.name
      result[:rival_elo] = black_elo
      result[:result] = self.result.split('-').first
    elsif black.name == player_name
      result[:avg_err] = black_avg_error
      result[:std_dev] = black_std_deviation
      result[:perfect] = black_perfect_rate
      result[:blunders] = black_blunder_rate
      result[:color] = 'color.black'
      result[:elo] = black_elo
      result[:rival] = white.name
      result[:rival_elo] = white_elo
      result[:result] = self.result.split('-').last
    end
    result
  end

  def set_statistics!
    self.white_avg_error = avg_error(moves.white)
    self.black_avg_error = avg_error(moves.black)
    self.white_std_deviation = standard_deviation(moves.white)
    self.black_std_deviation = standard_deviation(moves.black)
    self.white_perfect_rate = perfect_rate(moves.white)
    self.black_perfect_rate = perfect_rate(moves.black)
    self.white_blunder_rate = blunder_rate(moves.white, tie_threshold, blunder_threshold)
    self.black_blunder_rate = blunder_rate(moves.black, tie_threshold, blunder_threshold)
    self.save!
  end

  def reset_statistics!
    white_avg_error = nil
    black_avg_error = nil
    white_std_deviation = nil
    black_std_deviation = nil
    white_perfect_rate = nil
    black_perfect_rate = nil
    white_blunder_rate = nil
    black_blunder_rate = nil
    player_out_db_ref = nil
    move_out_db_ref = nil
    value_out_db_ref = nil
    best_value_out_db_ref = nil
    deviation_out_db_ref = nil
    save!
  end

  def analyze(time, tie_threshold, blunder_threshold, ref_db=nil)
    puts 'Analyzing!'
    puts "game #{self.id}"
    puts "time #{time}"
    puts "tie_threshold #{tie_threshold}"
    puts "blunder_threshold #{blunder_threshold}"

    analyzer = GameAnalyzer.new [self], time, tie_threshold, blunder_threshold, ref_db

    start_processing
    analyzer.analyze_games
    finished_processing
  end

  def background_analyze(time, tie_threshold, blunder_threshold)
    background do
      analyze time, tie_threshold, blunder_threshold
    end
  end

  def processing?
    self.status == STATUS[:processing]
  end

  def progress_percentage
    (progress || 0) * 100
  end

  def start_processing
    update_attributes status: STATUS[:processing], progress: 0
  end

  def finished_processing
    update_attributes status: STATUS[:processed]
  end

  def to_pgn
    pgn = ''
    AVAILABLE_TAGS.keys.each do |tag|
      value = get_tag(tag)
      if value
        pgn += "[#{tag} \"#{value}\"]\n"
      end
    end
    pgn += "[PlayerOutOfDB-Ref \"#{player_out_db_ref}\"]\n"
    pgn += "[MoveNumberOutOfDB-Ref \"#{move_out_db_ref}\"]\n"
    pgn += "[ValueOutOfDB-Ref \"#{'%.2f' % value_out_db_ref}\"]\n"
    pgn += "[ValueBestMoveOutOfDB-Ref \"#{'%.2f' % best_value_out_db_ref}\"]\n"
    pgn += "[DeviationOutOfDB-Ref \"#{'%.2f' % deviation_out_db_ref}\"]\n"
    pgn += "\n"
    pgn += moves.map { |m| m.to_pgn }.join("\n")
    pgn += " #{self.result}"
    pgn
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
