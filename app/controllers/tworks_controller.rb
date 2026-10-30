class TworksController < ApplicationController
  before_action :set_twork, only: %i[ show edit update destroy ]

  # GET /tworks or /tworks.json
  def index
    if params[:q].present?
      session["q"] = (params[:q] || params["q"]).respond_to?(:to_unsafe_h) ? (params[:q] || params["q"]).to_unsafe_h : (params[:q] || params["q"])

      session[:page] = 1
    end

    q_params = session["q"].presence || {}
    @q = Twork.ransack(q_params)
    @tworks = @q.result.page(params[:page]).per(15)
  end

  # GET /tworks/1 or /tworks/1.json
  def show
  end

  # GET /tworks/new
  def new
    @twork = Twork.new
  end

  # GET /tworks/1/edit
  def edit
  end

  # POST /tworks or /tworks.json
  def create
    @twork = Twork.new(twork_params)

    respond_to do |format|
      if @twork.save
        format.html { redirect_to @twork, notice: "Twork was successfully created." }
        format.json { render :show, status: :created, location: @twork }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @twork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tworks/1 or /tworks/1.json
  def update
    respond_to do |format|
      if @twork.update(twork_params)
        format.html { redirect_to @twork, notice: "Twork was successfully updated." }
        format.json { render :show, status: :ok, location: @twork }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @twork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tworks/1 or /tworks/1.json
  def destroy
    @twork.destroy

    respond_to do |format|
      format.html { redirect_to tworks_path, status: :see_other, notice: "Twork was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twork
      @twork = Twork.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def twork_params
      params.require(:twork).permit(:no, :delivery_number, :delivery_date, :tinfo05, :tinfo07, :quote_number, :quantity, :unit_price, :billing_amount, :cost1, :cost2, :cost3, :total_cost, :profit, :profit_margin, :contractor1, :contractor2, :contractor3, :customer_code, :remarks, :staff, :den_code, :outsourcing_cost, :purchase_cost, :work_time, :work_cost)
    end
end
