Rails.application.routes.draw do
  resource :buildings
  root 'buildings#index'
end
