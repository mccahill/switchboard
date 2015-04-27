require 'test_helper'

class MonitorGlueControllerTest < ActionController::TestCase
  test "should get status" do
    get :status
    assert_response :success
  end

end
