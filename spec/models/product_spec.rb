require 'rails_helper'

RSpec.describe Product, type: :model do
  let!(:product){create(:product)}
  let!(:related_product){create(:product)}
  let!(:second_related_product){create(:product)}

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:price) }
  it { is_expected.to validate_presence_of(:quantity) }

  it { is_expected.to belong_to(:main_product).optional.class_name("Product") }

  describe 'related product' do
    context 'when add many' do
      before do
        product.related_products << related_product
        product.related_products << second_related_product
      end

      it 'has one related product' do
        expect(product.related_products.first).to eq(related_product)
      end
  
      it 'has many related products' do
        expect(product.related_products.count).to eq(2)
      end
    end

    context 'when invalid' do
      it 'has error' do
        product.related_products << product
        
        expect(product.errors.any?).to be_truthy
      end

      it 'counts 0 related product' do
        product.related_products << product

        expect(product.reload.related_products.count).to eq(0)
      end

      it 'invalid to main product' do
        product.related_products << product

        expect(product.valid?).to be_falsey
      end
    end

    context 'when remove' do
      before do
        product.related_products << related_product
      end

      it 'counts 0' do
        product.related_products.delete(related_product)
        expect(product.related_products.count).to eq(0)
      end
    end
  end
end
