class AddReferenceToDiscount < ActiveRecord::Migration[6.1]
  def change
    remove_column :products, :discount
    add_reference :products, :discount, foreign_key: true
  end
end
