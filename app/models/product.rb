class Product < ApplicationRecord
  with_options presence: true do
    validates :name, uniqueness: true
    validates :description
    validates :price
    validates :quantity
  end

  validate :self_related_product, on: :update

  belongs_to :main_product, class_name: "Product", foreign_key: "related_product_id", optional: true

  has_many :related_products, class_name: "Product", dependent: :nullify, foreign_key: "related_product_id"

  def self_related_product
    if id.eql? related_product_id
      errors.add(:related_product, "can't relate to itself!")
    end
  end
end
