class AddDataController < ApplicationController
  include AddValuesHelper
  before_action :set_add_datum, only: %i[ show edit update destroy ]
  def index
  end

  def new
  end

  def create
    @job = Job.find(params["add_datum"]["job_id"])
    if params["add_datum"].is_a?(ActionController::Parameters)
      # transform_values! を使って、ハッシュの全ての値を書き換える
      params["add_datum"].transform_values! do |value|
        # 値が文字列(String)の場合のみ、カンマ(,)と空白( )を削除する
        value.is_a?(String) ? value.delete(", ") : value
      end
    end
    @add_datum = AddDatum.new(add_datum_params)
    respond_to do |format|
      if @add_datum.save
        format.html { redirect_to job_path(@job,i: params[:i],ii: params[:ii], p: params[:p]) }

      else
        format.html { render :new, status: :unprocessable_entity }

      end
    end
  end

  def update
    @job = Job.find(params["add_datum"]["job_id"])

    if params["add_datum"].is_a?(ActionController::Parameters)
      # transform_values! を使って、ハッシュの全ての値を書き換える
      params["add_datum"].transform_values! do |value|
        # 値が文字列(String)の場合のみ、カンマ(,)と空白( )を削除する
        value.is_a?(String) ? value.delete(", ") : value
      end
    end

    respond_to do |format|
      if @add_datum.update(add_datum_params)
        format.html {  redirect_to job_path(@job,i: params[:i],ii: params[:ii], p: params[:p])  }

      else
        format.html { render :new, status: :unprocessable_entity }

      end
    end
  end
  def edit_parent_code
    @job = Job.find(params[:job_id])
    @add_datum = AddDatum.find_or_initialize_by(job_id: @job.id)
    render partial: 'add_data/parent_code_form', locals: { add_datum: @add_datum }
  end

  def update_parent_code
    @job = Job.find(params[:job_id])
    @add_datum = AddDatum.find_or_initialize_by(job_id: @job.id)

    if @add_datum.update(add_datum_params)
      info = @job.info
      # We need to re-render all the add_value rows for the job]
      rows_html = ''
      values = @job.add_values.order(:id).to_a
      if values.any?
        values.each_with_index do |val, i|
          rows_html << render_to_string(
            partial: 'add_values/row',
            formats: [:html],
            layout: false,
            locals: { value: val, job: @job, info: info, idx: 0, offset: 0, idv: i, show_add_link: true }
          )
        end

      else
        placeholder = AddValue.new(job: @job)
        rows_html << render_to_string(
          partial: 'add_values/row',
          formats: [:html],
          layout: false,
          locals: { value: placeholder, job: @job, info: info, idx: 0, offset: 0, idv: 0, show_add_link: true }
        )
      end

      # add_values/index のジョブ一覧で差し替える親コードセル HTML
      parent_cell_html = render_to_string(
        partial: 'add_values/parent_code_cell',
        formats: [:html],
        layout: false,
        locals: { job: @job, add_datum: @add_datum }
      )

      render json: { status: 'success', html: rows_html, job_id: @job.id, parent_cell_html: parent_cell_html }
    else
      puts "error"
      render json: { status: 'error', errors: @add_datum.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_add_datum
    @add_datum = AddDatum.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def add_datum_params
    params.require(:add_datum).permit(:n01, :n02, :n03, :job_id, :sales_price, :iroko_num, :out_cost, :assembly, :delivery, :ctp, :pod, :kako, :dtp, :parent_code ,:vprice )
  end
end
