class CreatePgnFiles < ActiveRecord::Migration
  def change
    create_table :pgn_files do |t|
      t.string :description
      t.string :pgn_file
      t.integer :status

      t.timestamps
    end
  end
end
