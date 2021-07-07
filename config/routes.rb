Rails.application.routes.draw do
  post 'register', to: 'users#create'
  post 'authenticate', to: 'authentication#authenticate'
  post 'referral', to: 'referrals#create'
end
