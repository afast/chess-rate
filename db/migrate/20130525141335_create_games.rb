class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :white_id
      t.integer :black_id
      t.integer :pgn_file_id
      t.string :annotator
      t.float :white_avg_error
      t.float :black_avg_error
      t.integer :tournament_id
      t.integer :site_id
      t.datetime :start_date
      t.integer :round
      t.integer :result
      t.integer :status
      t.datetime :end_date
      t.float :white_std_deviation
      t.float :black_std_deviation
      t.float :white_perfect_rate
      t.float :black_perfect_rate
      t.float :black_blunder_rate
      t.float :white_blunder_rate

      t.timestamps
    end
  end
end
