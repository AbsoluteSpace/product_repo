require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get purchased" do
    get "/purchased"
    assert_response :success
  end

  test "should get admin" do
    get "/admin"
    assert_response :success
  end

  test "should get about" do
    get "/about"
    assert_response :success
  end
end
