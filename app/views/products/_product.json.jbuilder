json.extract! product, :id, :name, :description, :price, :quantity, :created_at, :updated_at
if related_products.present?
    json.related_products related_products, :id, :name, :price
end
