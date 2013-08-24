class CreateReferenceDatabases < ActiveRecord::Migration
  def change
    create_table :reference_databases do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
