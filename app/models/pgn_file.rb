class PgnFile < ActiveRecord::Base
  include Background

  STATUS = {not_processed: 0, processing: 1, processed: 2}
  STATUS_TEXT = {0 => 'Not yet Processed', 1 => 'Processing', 2 => 'Processed'}

  mount_uploader :pgn_file, PgnFileUploader

  has_many :games
  has_many :moves, through: :games

  before_create :init_status

  attr_accessible :description, :pgn_file, :status, :average_perfect, :average_distance
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

  def start_processing
    update_attributes status: STATUS[:processing]
  end

  def finished_processing
    update_attributes status: STATUS[:processed]
  end

  def analyze(time, tie_threshold, blunder_threshold)
    background do
      if games.empty?
        SimpleParser.new.parse self.id, pgn_file.file.file
      end

      if games.reload.not_processed.any?
        games.not_processed.each do |g|
          g.analyze(time, tie_threshold, blunder_threshold, @reference_database)
        end
      else
        games.each do |g|
          g.analyze(time, tie_threshold, blunder_threshold, @reference_database)
        end
      end
      finished_processing
    end
  end
end
