class DebitsController < ApplicationController
  before_action :set_debit, only: %i[ show edit update destroy ]

  # GET /debits or /debits.json
  def index
    @debits = Debit.all
  end

  # GET /debits/1 or /debits/1.json
  def show
  end

  # GET /debits/new
  def new
    @debit = Debit.new
  end

  # GET /debits/1/edit
  def edit
  end

  # POST /debits or /debits.json
  def create
    @debit = Debit.new(debit_params)

    respond_to do |format|
      if @debit.save
        format.html { redirect_to @debit, notice: "Debit was successfully created." }
        format.json { render :show, status: :created, location: @debit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @debit.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_job
    debits = Debit.where(job_id: nil).where.not(den_code: nil)
    puts debits&.count
    debits.each do |debit|
      job = Job.find_by("den_id = ?", debit.den_code)
      if job.present?
        debit.job_id = job.id
        debit.save
      end
    end
    redirect_to debits_path
  end

  # PATCH/PUT /debits/1 or /debits/1.json
  def update
    respond_to do |format|
      if @debit.update(debit_params)
        format.html { redirect_to @debit, notice: "Debit was successfully updated." }
        format.json { render :show, status: :ok, location: @debit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @debit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /debits/1 or /debits/1.json
  def destroy
    @debit.destroy

    respond_to do |format|
      format.html { redirect_to debits_path, status: :see_other, notice: "Debit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_debit
      @debit = Debit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def debit_params
      params.require(:debit).permit(:target_month, :den_code, :job_id, :siwake, :name, :out_cost, :in_cost)
    end
end
