require 'test_helper'

class ReferenceDatabasesControllerTest < ActionController::TestCase
  setup do
    @reference_database = reference_databases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reference_databases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reference_database" do
    assert_difference('ReferenceDatabase.count') do
      post :create, reference_database: { name: @reference_database.name, path: @reference_database.path }
    end

    assert_redirected_to reference_database_path(assigns(:reference_database))
  end

  test "should show reference_database" do
    get :show, id: @reference_database
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reference_database
    assert_response :success
  end

  test "should update reference_database" do
    put :update, id: @reference_database, reference_database: { name: @reference_database.name, path: @reference_database.path }
    assert_redirected_to reference_database_path(assigns(:reference_database))
  end

  test "should destroy reference_database" do
    assert_difference('ReferenceDatabase.count', -1) do
      delete :destroy, id: @reference_database
    end

    assert_redirected_to reference_databases_path
  end
end
