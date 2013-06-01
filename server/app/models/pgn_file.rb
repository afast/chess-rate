class PgnFile < ActiveRecord::Base
  include Background

  STATUS = {not_processed: 0, processing: 1, processed: 2}
  STATUS_TEXT = {0 => 'Not yet Processed', 1 => 'Processing', 2 => 'Processed'}

  mount_uploader :pgn_file, PgnFileUploader

  has_many :games

  before_create :init_status

  attr_accessible :description, :pgn_file, :status

  def init_status
    status = STATUS[:not_processed]
  end

  def status_to_s
    STATUS_TEXT[status || 0]
  end

  def not_processed?
    status.nil? || status == STATUS[:not_processed]
  end

  def start_processing
    update_attributes status: STATUS[:processing]
  end

  def finished_processing
    update_attributes status: STATUS[:processed]
  end

  def analyze(time, tie_threshold, blunder_threshold)
    background do
      self.games.destroy_all
      puts 'Start parsing data...'
      tree = Parser.parse pgn_file.file.read
      puts 'Finished Parsing'

      tree.get_games self
      games.each do |g|
        g.analyze(time, tie_threshold, blunder_threshold)
      end
      finished_processing
    end
  end
end
