class AddAverageFieldsToPgnFile < ActiveRecord::Migration
  def change
    add_column :pgn_files, :average_distance, :float
    add_column :pgn_files, :average_perfect, :float
  end
end
