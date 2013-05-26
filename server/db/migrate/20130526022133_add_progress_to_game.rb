class AddProgressToGame < ActiveRecord::Migration
  def change
    add_column :games, :progress, :float
    add_column :games, :tie_threshold, :float
    add_column :games, :blunder_threshold, :float
  end
end
