require 'test_helper'

class SdnCallbackControllerTest < ActionController::TestCase
  test "should get restore_state" do
    get :restore_state
    assert_response :success
  end

end
