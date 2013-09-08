ChessRate::Application.routes.draw do
  resources :fen_moves

  resources :reference_databases

  root to: 'games#index'

  devise_for :users

  resources :players
  resources :sites
  resources :tournaments
  resources :moves
  resources :games do
    member do
      get :analyze, to: :setup_analysis
      get :progress
      get :download
      get :statistics
      post :analyze
    end
  end

  resources :users
  resources :pgn_files do
    member do
      get :analyze, to: :setup_analysis
      post :analyze
      post :reset_stats
    end
  end
end
