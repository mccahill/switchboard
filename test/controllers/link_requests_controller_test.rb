require 'test_helper'

class LinkRequestsControllerTest < ActionController::TestCase
  setup do
    @link_request = link_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:link_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create link_request" do
    assert_difference('LinkRequest.count') do
      post :create, link_request: {  }
    end

    assert_redirected_to link_request_path(assigns(:link_request))
  end

  test "should show link_request" do
    get :show, id: @link_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @link_request
    assert_response :success
  end

  test "should update link_request" do
    patch :update, id: @link_request, link_request: {  }
    assert_redirected_to link_request_path(assigns(:link_request))
  end

  test "should destroy link_request" do
    assert_difference('LinkRequest.count', -1) do
      delete :destroy, id: @link_request
    end

    assert_redirected_to link_requests_path
  end
end
