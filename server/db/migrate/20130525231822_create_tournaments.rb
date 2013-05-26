class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :name
      t.integer :site_id
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
