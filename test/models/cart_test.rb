require "test_helper"

class CartTest < ActiveSupport::TestCase
# test "the truth" do
#   assert true
# end
test "add unique products to cart" do
  cart = carts(:one)
  product = products(:pragprog)

  assert_difference("cart.line_items.count", 1) do
    cart.add_product(product).save!
  end

  assert_equal 1, cart.line_items.find_by!(product: product).quantity
end

  test "add duplicate products to cart" do
    cart = carts(:one)
    product = products(:pragprog)

    cart.add_product(product).save!

    assert_no_difference("cart.line_items.count") do
      item = cart.add_product(product)
      assert_equal 2, item.quantity
      item.save!
    end
  end
end
