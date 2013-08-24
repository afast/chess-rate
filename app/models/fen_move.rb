class FenMove < ActiveRecord::Base
  belongs_to :reference_database
  attr_accessible :black, :reference_database_id, :draw, :move, :white

  def calculate
    [(white + draw/2.0)/(white + draw + black)*100.0, (white + draw + black)]
  end

end
