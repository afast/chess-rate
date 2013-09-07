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

    avg = moves.average(:distance)
    self.update_attributes average_distance: avg
    avg
  end

  def avg_perfect
    return average_perfect if average_perfect
    arr = games.pluck(:total_perfect_rate).compact
    avg = 0
    if arr.size > 0
      avg = arr.sum / arr.size
      self.update_attributes average_perfect: avg
    end
    avg
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

      games.reload.each do |g|
        g.analyze(time, tie_threshold, blunder_threshold, @reference_database)
      end
      finished_processing
    end
  end
end
