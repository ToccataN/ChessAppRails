require 'test_helper'

class ChessControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get chess_new_url
    assert_response :success
  end

end
