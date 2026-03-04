class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :stock
      t.integer :category_id
      t.string :sku
      t.boolean :active

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
