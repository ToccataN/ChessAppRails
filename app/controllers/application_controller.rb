class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
def test
  render :html => "I love me some #{params[:cookies]} with my #{params[:cream]}"
end

end
