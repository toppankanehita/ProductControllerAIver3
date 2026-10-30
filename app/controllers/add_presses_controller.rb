class AddPressesController < ApplicationController
  before_action :set_add_press, only: %i[ show edit update destroy ]

  # GET /add_presses or /add_presses.json
  def index
    @add_presses = AddPress.all
  end

  # GET /add_presses/1 or /add_presses/1.json
  def show
  end

  # GET /add_presses/new
  def new
    @add_press = AddPress.new
  end

  # GET /add_presses/1/edit
  def edit
  end

  # POST /add_presses or /add_presses.json
  def create
    @job = Job.find(params["id"])
    #@add_press = AddPress.new(add_press_params)
    @form = Form::AddPressCollection.new(add_press_collection_params)
    respond_to do |format|
      if @form.save
        format.html { redirect_to job_path(@job,i: params[:i],ii: params[:ii], p: params[:p]) }
        format.json { render :show, status: :created, location: @add_press }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @add_press.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /add_presses/1 or /add_presses/1.json
  def update
    respond_to do |format|
      if @add_press.update(add_press_params)
        format.html { redirect_to job_path(@add_press.job_id,page: params[:page]), notice: "Add press was successfully updated." }
        format.json { render :show, status: :ok, location: @add_press }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @add_press.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /add_presses/1 or /add_presses/1.json
  def destroy
    @add_press.destroy

    respond_to do |format|
      format.html { redirect_to add_presses_url, notice: "Add press was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_add_press
      @add_press = AddPress.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def add_press_params
      params.require(:add_press).permit(:position,  :press_num,  :men,  :jisu,  :machine,  :han,  :iro,  :dai,  :kake,  :daitanka,  :tanka,  :dai_price,  :job_id, :zara, :toku, :kin, :upo, :iroa, :irob,:kake2,:page, :sasi)
    end


  def add_press_collection_params
    params
      .require(:form_add_press_collection)
      .permit(add_presses_attributes: [:id, :position,  :press_num,  :men,  :jisu,  :machine,  :han,  :iro,  :dai,  :kake,  :daitanka,  :tanka,  :dai_price,  :job_id, :zara, :toku, :kin, :upo, :iroa, :irob, :kake2,:page, :sasi])
  end
end
