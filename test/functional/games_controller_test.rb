require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post :create, game: { annotator: @game.annotator, black_avg_error: @game.black_avg_error, black_blunder_rate: @game.black_blunder_rate, black_id: @game.black_id, black_perfect_rate: @game.black_perfect_rate, black_std_deviation: @game.black_std_deviation, end_date: @game.end_date, result: @game.result, round: @game.round, site_id: @game.site_id, start_date: @game.start_date, status: @game.status, tournament_id: @game.tournament_id, white_avg_error: @game.white_avg_error, white_blunder_rate: @game.white_blunder_rate, white_id: @game.white_id, white_perfect_rate: @game.white_perfect_rate, white_std_deviation: @game.white_std_deviation }
    end

    assert_redirected_to game_path(assigns(:game))
  end

  test "should show game" do
    get :show, id: @game
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game
    assert_response :success
  end

  test "should update game" do
    put :update, id: @game, game: { annotator: @game.annotator, black_avg_error: @game.black_avg_error, black_blunder_rate: @game.black_blunder_rate, black_id: @game.black_id, black_perfect_rate: @game.black_perfect_rate, black_std_deviation: @game.black_std_deviation, end_date: @game.end_date, result: @game.result, round: @game.round, site_id: @game.site_id, start_date: @game.start_date, status: @game.status, tournament_id: @game.tournament_id, white_avg_error: @game.white_avg_error, white_blunder_rate: @game.white_blunder_rate, white_id: @game.white_id, white_perfect_rate: @game.white_perfect_rate, white_std_deviation: @game.white_std_deviation }
    assert_redirected_to game_path(assigns(:game))
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, id: @game
    end

    assert_redirected_to games_path
  end
end
