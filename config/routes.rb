# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :pins, only: [:index] do
  collection do
    post :toggle
  end
end
