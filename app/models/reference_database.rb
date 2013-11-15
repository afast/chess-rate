class ReferenceDatabase < ActiveRecord::Base
  has_many :fen_moves, dependent: :destroy
  validates :path, :name, uniqueness: true
  attr_accessible :name, :path

  mount_uploader :path, ReferenceDatabaseUploader

  before_validation :set_name
  after_create :generate

  def getPercentage(to_analyze)
    fen_move = fen_moves.where(move: to_analyze).first
    if fen_move.nil?
      return -1,0
    end
    return fen_move.calculate
  end

  private
  def generate
    DbRef::DbFactory.generate_DB_REF(path, self.id)
  end

  def set_name
    nameDb = String.new(path)
    nameDb.slice! ".pgn"
    nameDb = nameDb.split('\\').last
    self.name = nameDb
  end

end
