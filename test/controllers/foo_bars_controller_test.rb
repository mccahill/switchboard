require 'test_helper'

class FooBarsControllerTest < ActionController::TestCase
  setup do
    @foo_bar = foo_bars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:foo_bars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create foo_bar" do
    assert_difference('FooBar.count') do
      post :create, foo_bar: {  }
    end

    assert_redirected_to foo_bar_path(assigns(:foo_bar))
  end

  test "should show foo_bar" do
    get :show, id: @foo_bar
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @foo_bar
    assert_response :success
  end

  test "should update foo_bar" do
    patch :update, id: @foo_bar, foo_bar: {  }
    assert_redirected_to foo_bar_path(assigns(:foo_bar))
  end

  test "should destroy foo_bar" do
    assert_difference('FooBar.count', -1) do
      delete :destroy, id: @foo_bar
    end

    assert_redirected_to foo_bars_path
  end
end
