Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'
  post 'referral', to: 'referrals#create'
  post 'register', to: 'users#create'
  
end
