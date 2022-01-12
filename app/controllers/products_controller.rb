class ProductsController < ApplicationController
  before_action :set_product, only: %i[show update related_products remove_related destroy]
  before_action :set_related_product, only: [:related_products, :remove_related]
  before_action :set_related_products, only: [:show]

  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { errors: [error.message] }, status: :not_found
  end

  def index
    @products = Product.limit(params_limit).offset(page_params)
  end

  def show; end

  def create
    @product = Product.new(product_params)

    if @product.save
      render :show, status: :created, location: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render :show, status: :ok, location: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def related_products
    @product.related_products << @related_product
    if @related_product.valid?
      render :related_product, status: :created, location: @related_product
    else
      render json: { errors: @related_product.errors.full_messages }, status: :unprocessable_entity
    end 
  end

  def remove_related
    @product.related_products.delete(@related_product)
    render json: nil, status: :no_content
  end

  def destroy
    @product.destroy
  end

  def params_limit
    set_minor_limit
  end

  def page_params
    set_page_params
  end

  private

  def set_page_params
    page = params.fetch("page", 1).to_i - 1
    page * set_minor_limit
  end

  def set_minor_limit
    [
      params.fetch("limit", 20).to_i,
      100
    ].min
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def set_related_products
    @related_products = @product.related_products
  end

  def set_related_product
    @related_product = Product.find(params[:related_product_id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :quantity)
  end
end
