Rails.application.routes.draw do
 get '/:cookies/and/:cream' => 'application#test'

  root 'chess#new'
  post '/chess/:pos' => 'chess#select' 
  post '/chess/:piece/:square' => 'chess#move'
  get '/update', to: 'chess#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
