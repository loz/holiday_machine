HolidayMachine::Application.routes.draw do

  get "user_settings/change_manager"

  resources :calendar

  match 'vacations/holiday_json' => 'vacations#holiday_json'

  resources :vacations

  resources :user_days

  resources :settings

  resources :user_settings

  #TODO nest settings

  match 'administer/get_team_data' => 'administer#get_team_data'
  match 'administer/create' => 'administer#create'

  resources :administer

  devise_for :users, :admin

  #match 'vacations' => 'vacations#index', :as => 'user_root'

#  devise_scope :user do
#     get "sign_in", :to => "vacations"
#  end

  resources :home, :only => :index
  resources :admins, :only => :index

  root :to => 'home#index'

  get "info/registration_message"

#  match '/token' => 'home#token', :as => :token

end