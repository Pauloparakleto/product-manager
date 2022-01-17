class ProductsController < ApplicationController
  before_action :set_product, only: %i[show update related_products remove_related destroy]
  before_action :set_related_product, only: [:related_products, :remove_related]
  before_action :set_related_product_list, only: [:show]
  after_action :set_header_with_pagination, only: [:index]

  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { errors: [error.message] }, status: :not_found
  end

  def index
    @query = Product.ransack(params[:search_by])
    @products = @query.result.limit(params_limit).offset(page_params).order(sort_by_param)
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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_related_product_list
    @related_products = @product.related_products
  end

  def set_related_product
    @related_product = Product.find(params[:related_product_id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :quantity)
  end
end
