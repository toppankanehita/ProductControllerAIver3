class SizeListsController < ApplicationController
  before_action :set_size_list, only: %i[ show edit update destroy ]

  # GET /size_lists or /size_lists.json
  def index
    @size_lists = SizeList.all
  end

  # GET /size_lists/1 or /size_lists/1.json
  def show
  end

  # GET /size_lists/new
  def new
    @size_list = SizeList.new
  end

  # GET /size_lists/1/edit
  def edit
  end

  # POST /size_lists or /size_lists.json
  def create
    @size_list = SizeList.new(size_list_params)

    respond_to do |format|
      if @size_list.save
        format.html { redirect_to size_list_url(@size_list), notice: "Size list was successfully created." }
        format.json { render :show, status: :created, location: @size_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @size_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /size_lists/1 or /size_lists/1.json
  def update
    respond_to do |format|
      if @size_list.update(size_list_params)
        format.html { redirect_to size_list_url(@size_list), notice: "Size list was successfully updated." }
        format.json { render :show, status: :ok, location: @size_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @size_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /size_lists/1 or /size_lists/1.json
  def destroy
    @size_list.destroy

    respond_to do |format|
      format.html { redirect_to size_lists_url, notice: "Size list was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_size_list
      @size_list = SizeList.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def size_list_params
      params.require(:size_list).permit(:weight, :kind, :han, :weight_per_m)
    end
end
