class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.integer :parent_id
      t.integer :position

      t.timestamps
    end
    add_index :categories, :name, unique: true
  end
end
