require 'test_helper'

class NetConfigTransactionsControllerTest < ActionController::TestCase
  setup do
    @net_config_transaction = net_config_transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:net_config_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create net_config_transaction" do
    assert_difference('NetConfigTransaction.count') do
      post :create, net_config_transaction: { command: @net_config_transaction.command, description: @net_config_transaction.description, response: @net_config_transaction.response, status: @net_config_transaction.status, target: @net_config_transaction.target, who: @net_config_transaction.who }
    end

    assert_redirected_to net_config_transaction_path(assigns(:net_config_transaction))
  end

  test "should show net_config_transaction" do
    get :show, id: @net_config_transaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @net_config_transaction
    assert_response :success
  end

  test "should update net_config_transaction" do
    patch :update, id: @net_config_transaction, net_config_transaction: { command: @net_config_transaction.command, description: @net_config_transaction.description, response: @net_config_transaction.response, status: @net_config_transaction.status, target: @net_config_transaction.target, who: @net_config_transaction.who }
    assert_redirected_to net_config_transaction_path(assigns(:net_config_transaction))
  end

  test "should destroy net_config_transaction" do
    assert_difference('NetConfigTransaction.count', -1) do
      delete :destroy, id: @net_config_transaction
    end

    assert_redirected_to net_config_transactions_path
  end
end
