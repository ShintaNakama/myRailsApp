Rails.application.routes.draw do
  resources :profiles
  get 'forecasts/result/:id', to: 'forecasts#result',as: 'forecasts_result'



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
