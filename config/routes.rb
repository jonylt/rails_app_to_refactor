# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:create]

  # TODO: might be better to keep the logic inside the endpoint and controller users and add :show :destroy :index
  resource :user, only: [:show, :destroy]

  # TODO: rewrite this logic (similar to users)
  resources :todos do
    member do
      put 'complete'
      put 'incomplete'
    end
  end

  resources :todo_lists do
    resources :todos do
      member do
        put 'complete'
        put 'incomplete'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
