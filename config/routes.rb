Rails.application.routes.draw do
  get '/win' =>'endstate#win'

  get '/lose' => 'endstate#lose'

  get '/:cookies/and/:cream' => 'application#test'
  post '/chess/' => 'chess#new'
  root 'chess#pre'
  post '/chess/:pos' => 'chess#select' 
  post '/chess/:piece/:square' => 'chess#move'
  get '/update', to: 'chess#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
