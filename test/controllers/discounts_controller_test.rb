require "test_helper"

class DiscountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  should use_before_action(:verify_is_admin)

  def setup
    @percent_discount = discounts(:percent_discount)
    @amount_discount = discounts(:amount_discount)
    @post_discount = {name: "10off", percent_discount: true, discount: 10, tags: "tag1,tag4", all_tags: false, active: false}
    @product = products(:valid)
  end

  test "should get index if admin" do
    sign_in users(:admin)

    get "/discounts"
    assert_response :success
  end

  test "should get show if admin" do
    sign_in users(:admin)

    get "/discounts/#{@percent_discount.id}"
    assert_response :success
  end

  test "should get new if admin" do
    sign_in users(:admin)

    get "/discounts/new"
    assert_response :success
  end

  test "should post create if admin" do
    sign_in users(:admin)

    post "/discounts", params: {discount: @post_discount}
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "should render new if invalid_discount and admin on create" do
    sign_in users(:admin)

    @post_discount[:discount] = -10
    post "/discounts", params: {discount: @post_discount}
    assert_response :success
  end

  test "should get edit if admin" do
    sign_in users(:admin)
    get "/discounts/#{@percent_discount.id}/edit"
    assert_response :success
  end

  test "should patch update if admin" do
    sign_in users(:admin)

    patch "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "should render edit if invalid_discount and admin on update" do
    sign_in users(:admin)

    @post_discount[:discount] = -10
    patch "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :success
  end

  test "should delete if admin" do
    sign_in users(:admin)

    delete "/discounts/#{@percent_discount.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "should remove discount from product when deleted" do
    sign_in users(:admin)

    @product.reload
    assert @product.has_active_discount

    delete "/discounts/#{@percent_discount.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success

    @product.reload
    refute @product.has_active_discount
  end

  test "should get active if admin" do
    sign_in users(:admin)

    get "/discounts/active"
    assert_response :success
  end

  test "should redirect from new if not admin" do
    get "/discounts/new"
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    get "/discounts/new"
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from create if not admin" do
    post "/discounts", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    post "/discounts", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from edit if not admin" do
    get "/discounts/#{@percent_discount.id}/edit"
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    get "/discounts/#{@percent_discount.id}/edit"
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from update if not admin" do
    patch "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    patch "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from destroy if not admin" do
    delete "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    delete "/discounts/#{@percent_discount.id}", params: {discount: @post_discount}
    assert_response :redirect
    assert_redirected_to "/"
  end
end
