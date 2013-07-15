class FenMove < ActiveRecord::Base
  belongs_to :reference_database
  attr_accessible :black, :reference_database_id, :draw, :move, :white
end
