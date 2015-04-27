require 'test_helper'

class SwitchInitialConfigsControllerTest < ActionController::TestCase
  setup do
    @switch_initial_config = switch_initial_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:switch_initial_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create switch_initial_config" do
    assert_difference('SwitchInitialConfig.count') do
      post :create, switch_initial_config: { ip: @switch_initial_config.ip, switch_connection_type_id: @switch_initial_config.switch_connection_type_id, vlan: @switch_initial_config.vlan }
    end

    assert_redirected_to switch_initial_config_path(assigns(:switch_initial_config))
  end

  test "should show switch_initial_config" do
    get :show, id: @switch_initial_config
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @switch_initial_config
    assert_response :success
  end

  test "should update switch_initial_config" do
    patch :update, id: @switch_initial_config, switch_initial_config: { ip: @switch_initial_config.ip, switch_connection_type_id: @switch_initial_config.switch_connection_type_id, vlan: @switch_initial_config.vlan }
    assert_redirected_to switch_initial_config_path(assigns(:switch_initial_config))
  end

  test "should destroy switch_initial_config" do
    assert_difference('SwitchInitialConfig.count', -1) do
      delete :destroy, id: @switch_initial_config
    end

    assert_redirected_to switch_initial_configs_path
  end
end
