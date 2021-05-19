class CreateDiscounts < ActiveRecord::Migration[6.1]
  def change
    create_table :discounts do |t|
      t.string :name
      t.boolean :percent_discount
      t.decimal :discount
      t.text :tags, default: ""
      t.boolean :all_tags, default: false
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
