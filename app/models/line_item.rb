class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true
  validates :quantity, numericality: {
    greater_than: 0,
    message: "Quantity must be at least 1"
  }
  def total_price
    product.price * quantity
  end
end
