class PgnFile < ActiveRecord::Base
  include Background
  belongs_to :reference_database, foreign_key: :ref_db_id

  STATUS = {not_processed: 0, processing: 1, processed: 2}
  STATUS_TEXT = {0 => 'Not yet Processed', 1 => 'Processing', 2 => 'Processed'}

  mount_uploader :pgn_file, PgnFileUploader

  has_many :games
  has_many :moves, through: :games
  has_many :unprocessed_games, class_name: 'Game', conditions: {status: STATUS[:not_processed]}
  has_many :unprocessed_moves, through: :unprocessed_games, source: :moves

  before_create :init_status

  attr_accessible :description, :pgn_file, :status, :average_perfect, :average_distance,
    :time, :tie_threshold, :blunder_threshold, :ref_db_id
  attr_accessor :reference_database

  def init_status
    status = STATUS[:not_processed]
  end

  def avg_distance
    return average_distance if average_distance

    avg = moves.with_distance.average(:distance)
    self.update_attributes average_distance: avg
    avg || 0
  end

  def avg_perfect
    return average_perfect if average_perfect
    avg = if moves.with_distance.size > 0
      moves.perfect.size / moves.with_distance.size.to_f
    else
      0
    end
    self.update_attributes average_perfect: avg
    avg
  end

  def reset_stats
    avg = moves.with_distance.average(:distance)
    self.update_attributes average_distance: avg
    avg = if moves.with_distance.size > 0
      moves.perfect.size / moves.with_distance.size.to_f
    else
      0
    end
    self.update_attributes average_perfect: avg
  end

  def status_to_s
    STATUS_TEXT[status || 0]
  end

  def not_processed?
    status.nil? #|| status == STATUS[:not_processed]
  end

  def processing?
    status == STATUS[:processing]
  end

  def start_processing(time, tie_threshold, blunder_threshold, ref_db_id)
    update_attributes status: STATUS[:processing], time: time, tie_threshold: tie_threshold,
      blunder_threshold: blunder_threshold, ref_db_id: ref_db_id
  end

  def progress_percentage
    if games.any?
      (games.reload.processed.size.to_f / games.size.to_f) * 100
    else
      0
    end
  end

  def eta
    if processing? && self.unprocessed_moves.size > 0
      (self.unprocessed_moves.size * (self.time || 0)) / 1000
    else
      0
    end
  end

  def finished_processing
    update_attributes status: STATUS[:processed]
  end

  def analyze(time, tie_threshold, blunder_threshold)
    start_processing(time, tie_threshold, blunder_threshold, @reference_database.try(:id))
    background do
      begin
        if games.empty?
          SimpleParser.new.parse self.id, pgn_file.file.file
        end

        if games.reload.not_processed.any?
          games.not_processed.update_all(status: STATUS[:not_processed])
          games.processing.update_all(status: STATUS[:not_processed])
          games.not_processed.each do |g|
            begin
              g.analyze(time, tie_threshold, blunder_threshold, @reference_database)
            rescue
              logger.error $!
            end
          end
        else
          games.each do |g|
            begin
              g.analyze(time, tie_threshold, blunder_threshold, @reference_database)
            rescue
              logger.error $!
            end
          end
        end
        finished_processing
      rescue
        update_attributes status: STATUS[:not_processed]
        raise
      end
    end
  end
end
