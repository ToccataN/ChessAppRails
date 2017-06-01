Rails.application.routes.draw do
 

  get '/', to: 'chess#new'
  post '/chess/:pos' => 'chess#select' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
