require 'test_helper'

class PgnFilesControllerTest < ActionController::TestCase
  setup do
    @pgn_file = pgn_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pgn_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pgn_file" do
    assert_difference('PgnFile.count') do
      post :create, pgn_file: { file_name: @pgn_file.file_name, status: @pgn_file.status }
    end

    assert_redirected_to pgn_file_path(assigns(:pgn_file))
  end

  test "should show pgn_file" do
    get :show, id: @pgn_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pgn_file
    assert_response :success
  end

  test "should update pgn_file" do
    put :update, id: @pgn_file, pgn_file: { file_name: @pgn_file.file_name, status: @pgn_file.status }
    assert_redirected_to pgn_file_path(assigns(:pgn_file))
  end

  test "should destroy pgn_file" do
    assert_difference('PgnFile.count', -1) do
      delete :destroy, id: @pgn_file
    end

    assert_redirected_to pgn_files_path
  end
end
