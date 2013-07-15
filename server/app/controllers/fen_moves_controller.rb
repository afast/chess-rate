class FenMovesController < ApplicationController
  # GET /fen_moves
  # GET /fen_moves.json
  def index
    @fen_moves = FenMove.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fen_moves }
    end
  end

  # GET /fen_moves/1
  # GET /fen_moves/1.json
  def show
    @fen_move = FenMove.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fen_move }
    end
  end

  # GET /fen_moves/new
  # GET /fen_moves/new.json
  def new
    @fen_move = FenMove.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fen_move }
    end
  end

  # GET /fen_moves/1/edit
  def edit
    @fen_move = FenMove.find(params[:id])
  end

  # POST /fen_moves
  # POST /fen_moves.json
  def create
    @fen_move = FenMove.new(params[:fen_move])

    respond_to do |format|
      if @fen_move.save
        format.html { redirect_to @fen_move, notice: 'Fen move was successfully created.' }
        format.json { render json: @fen_move, status: :created, location: @fen_move }
      else
        format.html { render action: "new" }
        format.json { render json: @fen_move.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fen_moves/1
  # PUT /fen_moves/1.json
  def update
    @fen_move = FenMove.find(params[:id])

    respond_to do |format|
      if @fen_move.update_attributes(params[:fen_move])
        format.html { redirect_to @fen_move, notice: 'Fen move was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fen_move.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fen_moves/1
  # DELETE /fen_moves/1.json
  def destroy
    @fen_move = FenMove.find(params[:id])
    @fen_move.destroy

    respond_to do |format|
      format.html { redirect_to fen_moves_url }
      format.json { head :no_content }
    end
  end
end
