require 'test_helper'

class EndstateControllerTest < ActionDispatch::IntegrationTest
  test "should get win" do
    get endstate_win_url
    assert_response :success
  end

  test "should get lose" do
    get endstate_lose_url
    assert_response :success
  end

end
