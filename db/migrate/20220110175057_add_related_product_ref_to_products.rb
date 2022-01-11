class AddRelatedProductRefToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :related_product, null: true, foreign_key: false, index: true
  end
end
