class AddElosToGames < ActiveRecord::Migration
  def change
    add_column :games, :white_elo, :string
    add_column :games, :black_elo, :string
  end
end
