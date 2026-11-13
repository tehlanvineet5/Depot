class AddUniqueIndexToLineItems < ActiveRecord::Migration[8.1]
  def change
    add_index :line_items,
              [ :product_id, :cart_id ],
              unique: true,
              name: "index_line_items_on_product_and_cart"
  end
end
