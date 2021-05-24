class ProductsController < ApplicationController

  before_action :verify_is_admin, :except => [:index, :show, :purchase]

  def index
    @products = Product.page(params[:page])
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.apply_largest_discount

    if @product.save
      redirect_to @product
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      @product.discount.nil? ? @product.apply_largest_discount : @product.apply_largest_discount(true)
      redirect_to @product
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    redirect_to root_path
  end

  def purchase
    @product = Product.find(params[:id])
  end

  private
  def product_params
    params.require(:product).permit(:title, :body, :tags, :file_location, :price, :discount_price, :can_be_discounted, :has_active_discount, :active_discount_name)
  end

end
