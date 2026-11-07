require "application_system_test_case"

class CartsTest < ApplicationSystemTestCase
  test "add to cart and empty cart" do
    visit store_index_url

    assert_no_selector "#cart form"

    click_on "Add to Cart", match: :first

    assert_selector "#cart"
    assert_selector "#cart form"

    within "#cart" do
      find("form[action*='/carts/'] button").click
    end

    assert_no_selector "#cart form"
  end
    test "newly added item is highlighted" do
    visit store_index_url

    click_on "Add to Cart", match: :first

    assert_selector "#cart tr.line-item-highlight"
  end
end
