class CreateLists < ActiveRecord::Migration[8.1]
  def change
    create_table :lists do |t|
      t.text :title, null: false, index: { unique: true }
      t.text :description, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
