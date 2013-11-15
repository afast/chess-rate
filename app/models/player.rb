class Player < ActiveRecord::Base
  attr_accessible :name
  has_many :games_as_black, class_name: 'Game', foreign_key: :black_id
  has_many :games_as_white, class_name: 'Game', foreign_key: :white_id

  def games
    games_as_black + games_as_white
  end

  def moves
    games.collect(&:moves).flatten
  end

  def moves_white
    games_as_white.collect(&:moves).flatten
  end

  def moves_black
    games_as_black.collect(&:moves).flatten
  end

  def tournaments
    games.collect(&:tournament).uniq
  end

  def pgn_files
    PgnFile.where(id: games.collect(&:pgn_file_id).compact)
  end
end
