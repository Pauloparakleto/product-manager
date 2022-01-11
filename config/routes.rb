Rails.application.routes.draw do
  resources :products, defaults: { format: :json } do
    member do
      post :related_products
      delete "related_products", to: "products#remove_related"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
