class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.string :street, null: false
      t.string :city, null: false
      t.string :state
      t.string :zip_code, null: false
      t.string :country, null: false, default: "USA"
      t.string :address_type
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :addresses, [ :addressable_type, :addressable_id ]
    add_index :addresses, :address_type
  end
end
