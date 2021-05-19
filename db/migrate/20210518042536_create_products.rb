class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :title
      t.text :body, default: ""
      t.text :tags, default: ""
      t.text :file_location
      t.decimal :price
      t.decimal :discount_price
      t.boolean :can_be_discounted, default: true
      t.boolean :has_active_discount, default: false
      t.string :active_discount_name

      t.timestamps
    end
  end
end
