require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @product = products(:valid)
    @post_product = {title: @product.title, body: @product.body, tags: @product.tags,
    file_location: @product.file_location, price: @product.price,
    discount_price: @product.discount_price, can_be_discounted: @product.can_be_discounted,
    has_active_discount: @product.has_active_discount, discount: discounts(:percent_discount)}
  end

  test "should get index" do
    get "/"
    assert_response :success
  end

  test "should redirect from new if not admin" do
    get "/products/new"
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    get "/products/new"
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should get show" do
    get "/products/#{@product.id}"
    assert_response :success
  end

  test "should redirect from create if not admin" do
    post "/products", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    post "/products", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from edit if not admin" do
    get "/products/#{@product.id}/edit"
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    get "/products/#{@product.id}/edit"
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from update if not admin" do
    patch "/products/#{@product.id}", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    patch "/products/#{@product.id}", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should redirect from destroy if not admin" do
    delete "/products/#{@product.id}", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"

    sign_in users(:user)
    delete "/products/#{@product.id}", params: {product: @post_product}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "should get purchase" do
    get "/products/purchase/#{@product.id}"
    assert_response :success
  end

  test "should get new if admin" do
    sign_in users(:admin)
    get "/products/new"
    assert_response :success
  end

  test "should post create if admin" do
    sign_in users(:admin)

    @post_product["title"] = "new product"

    post "/products", params: {product: @post_product}
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "should get edit if admin" do
    sign_in users(:admin)
    get "/products/#{@product.id}/edit"
    assert_response :success
  end

  test "should patch update if admin" do
    sign_in users(:admin)
    @product.update_discount_attributes(false, nil, @product.price)
    refute @product.has_active_discount

    patch "/products/#{@product.id}", params: {product: @post_product}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    @product.reload
    assert @product.has_active_discount
  end

  test "should delete if admin" do
    sign_in users(:admin)

    delete "/products/#{@product.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
