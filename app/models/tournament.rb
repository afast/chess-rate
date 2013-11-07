class Tournament < ActiveRecord::Base
  attr_accessible :end_date, :name, :site_id, :start_date, :games

  belongs_to :site
  has_many :games

  def get_info_for(player_id)
    t = {}
    avg_error = 0
    avg_deviation = 0
    perfect_rate = 0
    blunder_rate = 0
    count = games.where(white_id: player_id).size + games.where(black_id: player_id).size
    games.where(white_id: player_id).each do |g|
      avg_error += g.white_avg_error if g.white_avg_error
      avg_deviation += g.white_std_deviation if g.white_std_deviation
      perfect_rate += g.white_perfect_rate if g.white_perfect_rate
      blunder_rate += g.white_blunder_rate if g.white_blunder_rate
    end
    games.where(black_id: player_id).each do |g|
      avg_error += g.black_avg_error if g.black_avg_error
      avg_deviation += g.black_std_deviation if g.black_std_deviation
      perfect_rate += g.black_perfect_rate if g.black_perfect_rate
      blunder_rate += g.black_blunder_rate if g.black_blunder_rate
    end
    t[:name] = name
    t[:start_date] = (start_date || games.minimum(:start_date)).try(:to_date)
    t[:end_date] = (end_date.try(:to_date) || games.maximum(:end_date) || games.maximum(:start_date)).try(:to_date)

    t[:avg_error] = avg_error / count
    t[:avg_deviation] = avg_deviation / count
    t[:perfect_rate] = (perfect_rate / count) * 100
    t[:blunder_rate] = blunder_rate / count
    t
  end
end
