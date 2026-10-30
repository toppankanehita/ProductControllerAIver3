class WelcomesController < ApplicationController
  def index
    if params[:reset].present?
      session.delete("q")
      session[:show] = nil
      redirect_to root_path and return
    end

    if params["q"].present?
      @q = Job.ransack(params[:q])
      session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
    elsif params[:show].present? && session[:show] == "show"
      @q = Job.ransack(session[:q])
      params[:page] = session[:page]
    else
      @q = Job.ransack(session[:q])
    end
    if params[:p].present?
      unless params[:page].present?
        params[:page] = 1
      end
      if params[:show] == "show"
        params[:page] = params[:p]
      end
    end
    params[:show] = ""
    @q.build_grouping({ :life_eq => 1 })
    #base_query = @q.result.includes(:info, :sales, :uploadfile, :reportitems,:add_values, slips: :impositions)
    # base_query = @q.result.includes(
    #   :info, :sales, :uploadfile, :reportitems, :add_values,
    #   slips: :impositions,
    #   uploadfile: :specs  # ← これを追加
    # )
    base_query = @q.result.left_outer_joins(:info)

    if @q.info_dateInfo03_lteq.present?
      @jobs = base_query.page(params[:page]).per(12).order('infos.dateInfo03 ASC')
    elsif @q.info_dateInfo05_lteq.present?
      @jobs = base_query.page(params[:page]).per(12).order('infos.dateInfo05 ASC')
    else
      @jobs = base_query.page(params[:page]).per(12).order('id desc')
    end
    session[:show] = ""
    puts "----q-----"
    puts params[:q]
    puts "----q-----"
  end

  def show
    @job = Job.find(params[:id])
    @info = @job.info
  end
end
