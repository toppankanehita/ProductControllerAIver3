class CostController < ApplicationController
  include ApplicationHelper
  include ListMissionHelper

  def index
    @costs = Cost.all.order("target_month desc")
  end

  def cal_cost
    @costs = Cost.all.order("target_month desc")
    cost = Cost.find_by(id: params[:id])

    if cost.present? && cost.target_month.present?
      # target_month ("202602") から月初と月末を算出
      begin
        start_date = Date.strptime(cost.target_month, "%Y%m")
        end_date = start_date.end_of_month

        # Sale モデルから該当期間の job_id を取得
        job_ids = Sale.where(sale_day: start_date..end_date).pluck(:job_id).compact.uniq
        jobs = Job.where(id: job_ids)
        if jobs.present?
          all_paper = 0
          all_paper_web = 0
          all_paper_sheet = 0
          all_press_web = 0
          all_press_sheet = 0
          all_roumu_product = 0
          all_roumu_create = 0
          all_roumu_design = 0
          all_assembly = 0
          all_outsourcing = 0
          all_ctp_plate = 0
          all_ctp_sheet = 0
          all_pod_cost = 0
          all_slip_sales = 0
          all_out_cost = 0
          all_in_cost = 0
          all_delivery_cost = 0
          all_web_minus = 0
          @mission = true
          for job in jobs
            mission_child_helper(job)
            mission_child_plus_helper(job)
            all_paper += @mission_array[48].to_i #全容器金額
            all_paper_web += @mission_array[0].to_i #用紙合計
            all_paper_sheet += @mission_array[11].to_i #用紙合計
            all_press_web += @mission_array[1].to_i #印刷基準値オフ輪
            all_press_sheet += @mission_array[2].to_i #印刷基準値枚葉
            all_roumu_product += @mission_array[4].to_i #労務製造
            all_roumu_create += @mission_array[6].to_i #労務制作
            all_roumu_design += @mission_array[8].to_i #労務デザイン
            all_assembly += @mission_array[10].to_i#アセンブリ
            all_outsourcing += @mission_array[12].to_i#全外注
            all_ctp_plate += @mission_array[13].to_i#オフ輪CTP
            all_ctp_sheet += @mission_array[17].to_i#枚葉CTP
            all_pod_cost += @mission_array[14].to_i#全POD
            all_slip_sales += @mission_array[18].to_i#受注No有り売上
            if job.info.textInfo02&.include?("外注") && ((@mission_array[4]).to_i + (@mission_array[6]).to_i + (@mission_array[8]).to_i + (@mission_array[10]).to_i) == 0
              #何も
            else
              all_out_cost += @mission_array[15].to_i#全外注費
              all_in_cost += @mission_array[16].to_i#全仕入高
            end
            all_delivery_cost += @mission_array[35].to_i #全発送料
            all_web_minus += @mission_array[47].to_i #オフ輪減額
          end
          cost.all_paper = all_paper
          cost.all_paper_web = all_paper_web
          cost.all_paper_sheet = all_paper_sheet
          cost.all_press_web = all_press_web
          cost.all_press_sheet = all_press_sheet
          cost.all_roumu_product = all_roumu_product
          cost.all_roumu_create = all_roumu_create
          cost.all_roumu_design = all_roumu_design
          cost.all_assembly = all_assembly
          cost.all_outsourcing = all_outsourcing
          cost.all_ctp_plate = all_ctp_plate
          cost.all_pod_cost = all_pod_cost
          cost.all_ctp_sheet = all_ctp_sheet
          cost.all_slip_sales = all_slip_sales
          cost.all_out_cost = all_out_cost
          cost.all_in_cost = all_in_cost
          cost.all_delivery_cost = all_delivery_cost
          cost.all_web_minus = all_web_minus
          cost.save

        end
      rescue Date::Error
        # 日付形式が不正な場合
        redirect_to cost_index_path, alert: "対象月の形式が正しくありません。" and return
      end
    end

    redirect_to cost_index_path
  end
end
