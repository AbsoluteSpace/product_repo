class DiscountsController < ApplicationController
  before_action :verify_is_admin

  def index
      @discounts = Discount.page(params[:page])
  end

  def show
      @discount = Discount.find(params[:id])
  end

  def new
      @discount = Discount.new
  end

  def create
      @discount = Discount.new(discount_params)

      if @discount.save
          @discount.update_site_discounts
          redirect_to @discount
      else
          render :new
      end
  end

  def edit
      @discount = Discount.find(params[:id])
  end

  def update
      @discount = Discount.find(params[:id])

      if @discount.update(discount_params)
          @discount.update_site_discounts
          redirect_to @discount
      else
          render :edit
      end
  end

  def destroy
      @discount = Discount.find(params[:id])
      @discount.destroy
  
      redirect_to action: "index"
  end

  def active
    @discounts = Discount.where(:active => true).order('created_at desc').page(params[:page])
  end

  private

  def discount_params
      params.require(:discount).permit(:name, :percent_discount, :discount, :tags, :all_tags, :active)
  end
end
