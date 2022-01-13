require 'rails_helper'

RSpec.describe '/products', type: :request do
  let(:valid_attributes) { attributes_for(:product, name: "Be the best product", price: 2.34) }
  let(:invalid_attributes) { valid_attributes.merge(price: nil) }

  describe 'GET /index' do
    let!(:product) { Product.create! valid_attributes }
    let!(:second_product) { Product.create! attributes_for(:product, name: "A great product", price: 1.99) }

    context 'when sorting by name' do
      before { get products_url, params: { sort_by: 'name'} }

      it { expect(response).to have_http_status(:ok) }

      it 'has second product on the first position' do
        expect(response.body).to include_json(
          [
            {
              id: second_product.id,
              name: second_product.name,
              description: second_product.description,
              price: second_product.price.as_json,
              quantity: second_product.quantity,
              created_at: second_product.created_at.as_json,
              updated_at: second_product.updated_at.as_json
            },
            {
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price.as_json,
              quantity: product.quantity,
              created_at: product.created_at.as_json,
              updated_at: product.updated_at.as_json
            }
          ]
        )
      end
    end
    
    context 'when sorting by price' do
      before { get products_url, params: { sort_by: 'price'} }

      it { expect(response).to have_http_status(:ok) }

      it 'has second product on the first position' do
        expect(response.body).to include_json(
          [
            {
              id: second_product.id,
              name: second_product.name,
              description: second_product.description,
              price: second_product.price.as_json,
              quantity: second_product.quantity,
              created_at: second_product.created_at.as_json,
              updated_at: second_product.updated_at.as_json
            },
            {
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price.as_json,
              quantity: product.quantity,
              created_at: product.created_at.as_json,
              updated_at: product.updated_at.as_json
            }
          ]
        )
      end
    end

    context 'wihout pagination params' do
      before { get products_url }

      it { expect(response).to have_http_status(:ok) }
  
      it 'renders a JSON response with a list of products' do
        expect(response.body).to include_json(
          [
            {
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price.as_json,
              quantity: product.quantity,
              created_at: product.created_at.as_json,
              updated_at: product.updated_at.as_json
            }
          ]
        )
      end
    end

    context 'with pagination' do
      before { get products_url, params: { page: 2, limit: 1} }

      it { expect(response).to have_http_status(:ok) }

      it 'renders a JSON response with the second product' do
        expect(response.body).to include_json(
          [
            {
              id: second_product.id,
              name: second_product.name,
              description: second_product.description,
              price: second_product.price.as_json,
              quantity: second_product.quantity,
              created_at: second_product.created_at.as_json,
              updated_at: second_product.updated_at.as_json
            }
          ]
        )
      end

      it 'has a max limit of 100' do
        expect(Product).to receive(:limit).with(100).and_call_original
        
        get products_url, params: { limit: 550 }
      end
    end
  end

  describe 'GET /show' do
    context 'with existent id' do
      let(:product) { Product.create! valid_attributes }
      let(:related_product) { Product.create! attributes_for(:product)}

      before do
        product.related_products << related_product
        get product_url(product), as: :json
      end

      it { expect(response).to have_http_status(:ok) }

      it 'renders a JSON response with the product' do
        expect(response.body).to include_json(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price.as_json,
          quantity: product.quantity,
          created_at: product.created_at.as_json,
          updated_at: product.updated_at.as_json,
          related_products: [
            {
              id: related_product.id,
              name: related_product.name,
              price: related_product.price.as_json
            }
          ]
        )
      end
    end

    context 'with non-existent id' do
      before { get product_url(22) }

      it { expect(response).to have_http_status(404) }

      it 'renders a JSON response with errors' do
        json_data = JSON.parse(response.body, symbolize_names: true)
        expect(json_data).to eq(errors: ["Couldn't find Product with 'id'=22"])
      end
    end
  end

  describe 'POST /products/:id/related_products/' do
    context 'with a related product found' do
      let(:main_product) { Product.create! valid_attributes }
      let(:related_product) { Product.create! attributes_for(:product) }

      before do
        post related_products_product_path(main_product), params: {related_product_id: related_product.id}, as: :json
      end
      
      it { expect(response).to have_http_status(201) }

      it 'renders a JSON response with the related product' do
        expect(response.body).to include_json(
          id: related_product.id,
          name: related_product.name,
          price: related_product.price.as_json          
        )
      end
    end

    context 'when not found related product' do
      let(:main_product) { Product.create! valid_attributes }
      let(:related_product) { Product.create! attributes_for(:product) }

      before do
        post related_products_product_path(main_product), params: {related_product_id: 93}, as: :json
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when not found main product' do
      let(:related_product) { Product.create! attributes_for(:product) }

      before do
        post related_products_product_path(93), params: {related_product_id: related_product.id}, as: :json
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when main product to itself' do
      let(:main_product) { Product.create! valid_attributes }

      before do
        post related_products_product_path(main_product.reload), params: {related_product_id: main_product.id}, as: :json
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'DELETE /products/:id/related_products/' do
    context 'with a related product found' do
      let(:main_product) { Product.create! valid_attributes }
      let(:related_product) { Product.create! attributes_for(:product) }

      before do
        main_product.related_products << related_product
        delete related_products_product_path(main_product), params: {related_product_id: related_product.id}
      end
      
      it { expect(response).to have_http_status(204) }
    end

    context 'when not found related product' do
      let(:main_product) { Product.create! valid_attributes }

      before do
        delete related_products_product_path(main_product), params: {related_product_id: 93}
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when not found main product' do
      let(:related_product) { Product.create! attributes_for(:product) }

      before do
        delete related_products_product_path(93), params: {related_product_id: related_product.id}
      end

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Product' do
        expect {
          post products_url, params: { product: valid_attributes }, as: :json
        }.to change(Product, :count).by(1)
      end

      it 'renders a JSON response with the new product' do
        post products_url, params: { product: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)

        expect(response.body).to include_json(
          id: a_kind_of(Integer),
          name: valid_attributes[:name],
          description: valid_attributes[:description],
          price: valid_attributes[:price].to_d.as_json,
          quantity: valid_attributes[:quantity],
          created_at: a_kind_of(String),
          updated_at: a_kind_of(String)
        )
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Product' do
        expect {
          post products_url, params: { product: invalid_attributes }, as: :json
        }.to change(Product, :count).by(0)
      end

      before do
        post products_url, params: { product: invalid_attributes }, as: :json
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it 'renders a JSON response with errors for the new product' do
        json_data = JSON.parse(response.body, symbolize_names: true)
        expect(json_data).to eq(errors: ["Price can't be blank"])
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:product) { Product.create! valid_attributes }
      let(:new_attributes) { { price: product.price + 10 } }

      it 'updates the requested product' do
        patch product_url(product), params: { product: new_attributes }, as: :json
        product.reload
        expect(product.price).to eq new_attributes[:price]
      end

      it 'renders a JSON response with the product' do
        patch product_url(product), params: { product: new_attributes }, as: :json
        expect(response).to have_http_status(:ok)

        expect(response.body).to include_json(
          id: product.id,
          name: product.name,
          description: product.description,
          price: new_attributes[:price].as_json,
          quantity: product.quantity,
          created_at: product.created_at.as_json,
          updated_at: product.reload.updated_at.as_json
        )
      end
    end

    context 'with invalid parameters' do
      let(:product) { Product.create! valid_attributes }

      before do
        patch product_url(product), params: { product: invalid_attributes }, as: :json
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it 'renders a JSON response with errors for the product' do
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested product' do
      product = Product.create! valid_attributes
      expect { delete product_url(product), as: :json }.to change(Product, :count).by(-1)
    end
  end
end
