require "test_helper"

class ProductTest < ActiveSupport::TestCase
  should validate_presence_of(:title)
  should validate_presence_of(:body)
  should validate_presence_of(:file_location)
  should validate_presence_of(:price)
  should validate_numericality_of(:price).is_greater_than(0)
  should validate_numericality_of(:discount_price).is_greater_than(0)
  should allow_value(%w(true false)).for(:can_be_discounted)
  should allow_value(%w(true false)).for(:has_active_discount)
  should belong_to(:discount).optional

  def setup
    @product = products(:valid)
    @product_without_discount = products(:no_discount)
    @product_without_tags = products(:no_tags)
    @percent_discount = discounts(:percent_discount)
    @amount_discount = discounts(:amount_discount)
  end

  test "valid product" do
    assert @product.valid?
  end

  test "invalid tags gives invalid product" do
    @product.tags = "tag1,tag2,>tag3"
    refute @product.valid?, "Product should be invalid when tags are formatted wrong."
    assert_includes(
      @product.errors.details[:tags],
      { error: Messages::MESSAGES[:tags][:invalid] }
    )
  end

  test "discount price is not less than price" do
    @product.discount_price = @product.price + 1
    refute @product.valid?, "Product should be invalid when discount price is larger than price."
    assert_includes(
      @product.errors.details[:discount_price],
      { error: Messages::MESSAGES[:products][:discount][:exceeds_price] }
    )
  end

  test "product can't have active discount without discount price." do
    @product.discount_price = nil
    refute @product.valid?, "Product should be invalid when has discount but none given."
    assert_includes(
      @product.errors.details[:discount_price],
      { error: Messages::MESSAGES[:products][:discount][:not_present] }
    )
  end

  test "product not discounted by discount without matching tags" do
    @percent_discount.update_site_discounts

    @product_without_tags.reload
    refute @product_without_tags.has_active_discount
  end

  test "update product discount" do
    refute @product_without_discount.has_active_discount

    @product_without_discount.apply_discount(@percent_discount)

    @product.reload
    assert @product_without_discount.has_active_discount
    assert @product_without_discount.discount_price == @product_without_discount.calculate_discount_price(@percent_discount)
    assert @product_without_discount.discount.name == @percent_discount.name
  end

  test "don't apply discount greater than price" do
    refute @product_without_discount.has_active_discount

    @amount_discount.update_column(:discount, @product_without_discount.price + 1)
    @product_without_discount.apply_discount(@amount_discount)

    @product.reload
    refute @product_without_discount.has_active_discount
  end

  test "no discount applied when discount doesn't reduce cost" do
    @percent_discount.update_column(:discount, 0)
    @product_without_discount.apply_discount(@percent_discount)

    @product.reload
    refute @product_without_discount.has_active_discount
  end

  test "discount doesn't apply to product that can't have discounts" do
    @product.disable_discounts
    @amount_discount.update_site_discounts

    @product.reload
    refute @product.has_active_discount
  end

  test "existing product that can now have discounts recieves largest discount" do
    @product.disable_discounts
    @product.reload
    @product.enable_discounts

    @product.reload
    assert @product.has_active_discount
    assert @product.discount.name = @percent_discount.name
  end

  test "largest discount is product-specific discount" do
    @product_without_discount.update_column(:discount_price, 0.01)
    @product_without_discount.update_column(:has_active_discount, true)
    @product_without_discount.apply_largest_discount

    @product_without_discount.reload
    assert @product_without_discount.has_active_discount
    assert @product_without_discount.discount.nil?
    assert @product_without_discount.discount_price = 0.01
  end
end
