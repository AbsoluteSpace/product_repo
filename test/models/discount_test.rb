require "test_helper"

class DiscountTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should allow_value(%w(true false)).for(:percent_discount)
  should validate_presence_of(:discount)
  should validate_numericality_of(:discount).is_greater_than(0)
  should validate_presence_of(:tags)
  should allow_value(%w(true false)).for(:all_tags)
  should allow_value(%w(true false)).for(:active)

  def setup
    @percent_discount = discounts(:percent_discount)
    @amount_discount = discounts(:amount_discount)
  end

  test "valid discount" do
    assert @percent_discount.valid?
    assert @amount_discount.valid?
  end

  test "percentage greater than 100 gives invalid discount" do
    @percent_discount.discount = 150
    refute @percent_discount.valid?, "Discount should be invalid with > 100 percent discount."
    assert_not_nil @percent_discount.errors[:name], "Percent discount > 100 should result in error."
  end

  test "invalid tags gives invalid discount" do
    @percent_discount.tags = "tag1,tag2,>tag3"
    refute @percent_discount.valid?, "Discount should be invalid when tags are formatted wrong."
    assert_not_nil @percent_discount.errors[:name], "Tags with wrong format should result in error."
  end

  test "amount discount can be greater than 100" do
    @amount_discount.discount = 101
    assert @amount_discount.valid?
  end

  # test for decimals up to 2 for discount

end
