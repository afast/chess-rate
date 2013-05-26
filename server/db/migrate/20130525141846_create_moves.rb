class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.boolean :side
      t.string :pgn
      t.string :lan
      t.float :player_value
      t.string :annotator_move
      t.float :annotator_value
      t.integer :number
      t.integer :status
      t.text :comments
      t.boolean :check
      t.boolean :mate

      t.timestamps
    end
  end
end
