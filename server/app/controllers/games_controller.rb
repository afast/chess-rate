class GamesController < ApplicationController
  include GamesHelper
  # GET /games
  # GET /games.json
  def index
    @games = Game.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  # GET /game/1/analyze
  def setup_analysis
    @game = Game.find(params[:id])
    @name = @game.tournament.try(:name)
    @description = "#{@game.white.name} vs. #{@game.black.name}"
  end

  # POST /game/1/analyze
  def analyze
    AnalyzeGameWorker.perform_async(params[:id], params[:time].to_i, params[:tie_threshold].to_f, params[:blunder_threshold].to_f)
    redirect_to games_path
  end

  def progress
    render text: '%.2f' % (Game.find(params[:id]).progress_percentage)
  end

  def statistics
    render partial: 'statistics', locals: { game: Game.find(params[:id]) }
  end
end
