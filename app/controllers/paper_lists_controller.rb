class PaperListsController < ApplicationController
  before_action :set_paper_list, only: %i[ show edit update destroy ]

  # GET /paper_lists or /paper_lists.json
  def index
    @paper_lists = PaperList.all
    #@paper_lists = PaperList.joins(:paper_type).merge(PaperType.where(type: "特殊紙"))
  end

  # GET /paper_lists/1 or /paper_lists/1.json
  def show
  end

  # GET /paper_lists/new
  def new
    @paper_list = PaperList.new
  end

  # GET /paper_lists/1/edit
  def edit
  end

  # POST /paper_lists or /paper_lists.json
  def create
    @paper_list = PaperList.new(paper_list_params)

    respond_to do |format|
      if @paper_list.save
        format.html { redirect_to paper_list_url(@paper_list), notice: "Paper list was successfully created." }
        format.json { render :show, status: :created, location: @paper_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @paper_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /paper_lists/1 or /paper_lists/1.json
  def update
    respond_to do |format|
      if @paper_list.update(paper_list_params)
        format.html { redirect_to paper_list_url(@paper_list), notice: "Paper list was successfully updated." }
        format.json { render :show, status: :ok, location: @paper_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @paper_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paper_lists/1 or /paper_lists/1.json
  def destroy
    @paper_list.destroy

    respond_to do |format|
      format.html { redirect_to paper_lists_url, notice: "Paper list was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paper_list
      @paper_list = PaperList.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def paper_list_params
      params.require(:paper_list).permit(:name, :full_name, :ren, :han, :paper_type_id)
    end
end
