Rails.application.routes.draw do
  root 'main#index'

  get 'administration/index'

  get 'administration/show'
  # get 'administration/show', to: 'administration#index'
  # post 'administration/show'


  get 'main/index'

  get 'main/show'
  # get 'main/show', to: 'main#index'
  # post 'main/show'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
