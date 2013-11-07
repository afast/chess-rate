class ReferenceDatabasesController < ApplicationController
  # GET /reference_databases
  # GET /reference_databases.json
  def index
    @reference_databases = ReferenceDatabase.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reference_databases }
    end
  end

  # GET /reference_databases/1
  # GET /reference_databases/1.json
  def show
    @reference_database = ReferenceDatabase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reference_database }
    end
  end

  # GET /reference_databases/new
  # GET /reference_databases/new.json
  def new
    @reference_database = ReferenceDatabase.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reference_database }
    end
  end

  # GET /reference_databases/1/edit
  def edit
    @reference_database = ReferenceDatabase.find(params[:id])
  end

  # POST /reference_databases
  # POST /reference_databases.json
  def create
    @reference_database = ReferenceDatabase.new(params[:reference_database])

    respond_to do |format|
      if @reference_database.save
        format.html { redirect_to @reference_database, notice: 'Reference database was successfully created.' }
        format.json { render json: @reference_database, status: :created, location: @reference_database }
      else
        format.html { render action: "new" }
        format.json { render json: @reference_database.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reference_databases/1
  # PUT /reference_databases/1.json
  def update
    @reference_database = ReferenceDatabase.find(params[:id])

    respond_to do |format|
      if @reference_database.update_attributes(params[:reference_database])
        format.html { redirect_to @reference_database, notice: 'Reference database was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reference_database.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reference_databases/1
  # DELETE /reference_databases/1.json
  def destroy
    @reference_database = ReferenceDatabase.find(params[:id])
    @reference_database.destroy

    respond_to do |format|
      format.html { redirect_to reference_databases_url }
      format.json { head :no_content }
    end
  end
end
