require "test_helper"

class ProductTest < ActiveSupport::TestCase
  should validate_presence_of(:title)
  should validate_uniqueness_of(:title)
  should validate_presence_of(:body)
  should validate_presence_of(:tags)
  should validate_presence_of(:file_location)
  should validate_presence_of(:price)
  should validate_numericality_of(:price).is_greater_than(0)
  should validate_presence_of(:discount_price)
  should validate_numericality_of(:discount_price).is_greater_than(0)
  should allow_value(%w(true false)).for(:can_be_discounted)
  should allow_value(%w(true false)).for(:has_active_discount)
  should validate_presence_of(:active_discount_name)

  def setup
    @product = products(:valid)
  end

  test "valid product" do
    assert @product.valid?
  end

  test "invalid tags gives invalid product" do
    @product.tags = "tag1,tag2,>tag3"
    refute @product.valid?, "Product should be invalid when tags are formatted wrong."
    assert_not_nil @product.errors[:name], "Tags with wrong format should result in error."
  end

  test "discount price is not less than price" do
    @product.discount_price = @product.price + 1
    refute @product.valid?, "Product should be invalid when discount price is larger than price."
    assert_not_nil @product.errors[:name], "Discount price greater than price should result in error."
  end
end
