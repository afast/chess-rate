class PgnFilesController < ApplicationController
  # GET /pgn_files
  # GET /pgn_files.json
  def index
    @pgn_files = PgnFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pgn_files }
    end
  end

  # GET /pgn_files/1
  # GET /pgn_files/1.json
  def show
    @pgn_file = PgnFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pgn_file }
    end
  end

  # GET /pgn_files/new
  # GET /pgn_files/new.json
  def new
    @pgn_file = PgnFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pgn_file }
    end
  end

  # GET /pgn_files/1/edit
  def edit
    @pgn_file = PgnFile.find(params[:id])
  end

  # POST /pgn_files
  # POST /pgn_files.json
  def create
    @pgn_file = PgnFile.new(params[:pgn_file])

    respond_to do |format|
      if @pgn_file.save
        format.html { redirect_to @pgn_file, notice: 'Pgn file was successfully created.' }
        format.json { render json: @pgn_file, status: :created, location: @pgn_file }
      else
        format.html { render action: "new" }
        format.json { render json: @pgn_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pgn_files/1
  # PUT /pgn_files/1.json
  def update
    @pgn_file = PgnFile.find(params[:id])

    respond_to do |format|
      if @pgn_file.update_attributes(params[:pgn_file])
        format.html { redirect_to @pgn_file, notice: 'Pgn file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pgn_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pgn_files/1
  # DELETE /pgn_files/1.json
  def destroy
    @pgn_file = PgnFile.find(params[:id])
    @pgn_file.destroy

    respond_to do |format|
      format.html { redirect_to pgn_files_url }
      format.json { head :no_content }
    end
  end

  # GET /pgn_files/1/analyze
  def setup_analysis
    @pgn_file = PgnFile.find(params[:id])
  end

  # POST /pgn_files/1/analyze
  def analyze
    @pgn_file = PgnFile.find(params[:id])
    @pgn_file.reference_database = ReferenceDatabase.where(id: params[:reference_database_id]).first
    @pgn_file.analyze params[:time].to_i, params[:tie_threshold].to_f, params[:blunder_threshold].to_f
    redirect_to pgn_files_path
  end
end
