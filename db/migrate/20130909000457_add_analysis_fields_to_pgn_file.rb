class AddAnalysisFieldsToPgnFile < ActiveRecord::Migration
  def change
    add_column :pgn_files, :time, :integer
    add_column :pgn_files, :tie_threshold, :float
    add_column :pgn_files, :blunder_threshold, :float
    add_column :pgn_files, :ref_db_id, :integer
  end
end
