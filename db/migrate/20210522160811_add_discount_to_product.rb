class AddDiscountToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :discount, :belongs_to, index: { unique: true }
    remove_column :products, :active_discount_name
  end
end
