class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, :only => [:new, :pre]
def test
  render :html => "I love me some #{params[:cookies]} with my #{params[:cream]}"
end

end
