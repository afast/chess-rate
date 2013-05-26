class PgnFile < ActiveRecord::Base
  STATUS = {not_processed: 0, processing: 1, processed: 2}
  STATUS_TEXT = {0 => 'Not yet Processed', 1 => 'Processing', 2 => 'Processed'}

  mount_uploader :pgn_file, PgnFileUploader

  before_create :init_status

  attr_accessible :description, :pgn_file

  def init_status
    status = STATUS[:not_processed]
  end

  def status_to_s
    STATUS_TEXT[status || 0]
  end

  def not_processed?
    status.nil? || status == STATUS[:not_processed]
  end
end
