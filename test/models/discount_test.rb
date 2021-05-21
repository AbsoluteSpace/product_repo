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
    @product = products(:valid)
    @product_without_tags = products(:no_tags)
    @product_without_discount = products(:no_discount)
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

  test "deactivated discount does not apply" do
    @percent_discount.update_site_discounts

    @percent_discount.update_column(:active, false)
    @percent_discount.update_site_discounts

    @product.reload
    refute @product.has_active_discount, "Discount should not apply when it's inactive."
    assert @product.active_discount_name == ""
  end

  test "discount with all_tags should apply to every product" do
    @percent_discount.update_column(:all_tags, true)
    @percent_discount.update_site_discounts
    
    @product.reload
    @product_without_tags.reload

    assert @product_without_tags.has_active_discount, "Discount should apply when all tags."
    assert @product_without_tags.active_discount_name == @percent_discount.name
    assert @product.has_active_discount, "Discount should apply when all tags."
    assert @product.active_discount_name == @percent_discount.name
  end

  test "discount doesn't apply to product that can't be discounted" do
    @percent_discount.update_column(:all_tags, true)
    @product.disable_discounts

    @percent_discount.update_site_discounts
    
    @product.reload
    refute @product.has_active_discount, "Discount shouldn't discount product that can't be discounted."
  end

  test "updated discount should be reflected on products" do
    @percent_discount.update_site_discounts
    @product_without_discount.reload
    assert @product_without_discount.has_active_discount

    @percent_discount.update_column(:tags, "")
    @percent_discount.update_site_discounts

    @product_without_discount.reload
    assert @product_without_discount.active_discount_name != @percent_discount.name
  end

end
