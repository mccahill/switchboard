require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get subnets" do
    get :subnets
    assert_response :success
  end

  test "should get groups" do
    get :groups
    assert_response :success
  end

end
