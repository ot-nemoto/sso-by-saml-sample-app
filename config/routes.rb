Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, controllers: { registrations: 'users/registrations' }

  get 'aws/openam', action: :aws_openam, controller: 'home'
  get 'aws/onelogin', action: :aws_onelogin, controller: 'home'
end
