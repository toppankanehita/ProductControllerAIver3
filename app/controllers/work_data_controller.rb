class WorkDataController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def index
    @q = WorkDatum.ransack(params[:q])
    session["q"] = (params[:q] || params["q"]).respond_to?(:to_unsafe_h) ? (params[:q] || params["q"]).to_unsafe_h : (params[:q] || params["q"])
    #@q.result.page(params[:page]).per(15).order('id desc')
    @mission_archives = @q.result.page(params[:page]).per(50).order('id desc')
    @cost_sum = @mission_archives.sum(:mission_archive_43)
    @sales_sum = @mission_archives.sum(:mission_archive_44)

    @profit_sum = @mission_archives.sum(:mission_archive_45)
    @profit_par = ((@profit_sum.to_f / @sales_sum.to_f)) * 100
  end

  def work_data_set
    jobs = Job.joins(:info)
    if params[:month].present?
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - params[:month].to_i.month , 1 ).order('infos.dateInfo05 ASC')
    else
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - 2.month , 1 ).order('infos.dateInfo05 ASC')
    end
    i = 1
    @job_count = jobs.count
    jobs.find_each do |job|
      work_data_set_sub(job)
      info = job.info
      archive = WorkDatum.find_by(job_id: job.id)
      archive = archive.present? ? archive : WorkDatum.new(job_id: job.id)

      archive.mission_archive_01 = @mission_array[40]
      archive.mission_archive_02 = textInfo02_helper(info&.textInfo02)
      archive.mission_archive_03 = job.den_id
      archive.mission_archive_04 = info&.textInfo05
      archive.mission_archive_05 = info&.textInfo07
      archive.mission_archive_06 = info&.salesname
      archive.mission_archive_07 = numformat1(@tmp_array[0])
      archive.mission_archive_08 = numformat1(@tmp_array[1])
      archive.mission_archive_09 = numformat1(@tmp_array[0] + @tmp_array[1])
      archive.mission_archive_10 = numformat1(@tmp_array[3])
      archive.mission_archive_11 = numformat1(@mission_array[15])
      archive.mission_archive_12 = numformat1(@mission_array[16])
      archive.mission_archive_13 = number_with_precision(@mission_array[3],precision: 2)
      archive.mission_archive_14 = numformat1(@unit_price.d27)
      archive.mission_archive_15 = numformat1(@mission_array[4])
      archive.mission_archive_16 = number_with_precision(@mission_array[5],precision: 2)
      archive.mission_archive_17 = numformat1(@unit_price.d25)
      archive.mission_archive_18 = numformat1(@mission_array[6])
      archive.mission_archive_19 = number_with_precision(@mission_array[7],precision: 2)
      archive.mission_archive_20 = numformat1(@unit_price.d26)
      archive.mission_archive_21 = numformat1(@mission_array[8])
      archive.mission_archive_22 = number_with_precision(@mission_array[3] + @mission_array[5] + @mission_array[7],precision: 2)
      archive.mission_archive_23 = numformat1(@mission_array[4] + @mission_array[6] + @mission_array[8])
      archive.mission_archive_24 = number_with_precision(@mission_array[9],precision: 2)
      archive.mission_archive_25 = numformat1(@unit_price.d29)
      archive.mission_archive_26 = numformat1(@mission_array[10])
      archive.save





      i += 1
    end

    redirect_to work_data_path
  end

  def work_data_set_sub(job)
    @mitumori_array = Array.new(11)
    @tmp_array = Array.new(11)
    @roumu_array = Array.new(11)
    @mission_array = Array.new(48)
    @tmp_hiyou_sum = 0
    @mitumori_sum = 0
    @sale_sum = 0

    arari_cal_wap(job)

    @tmp_array[0] = @tmp_array[0].to_i + @papers[1].to_i
    @tmp_array[1] = @tmp_array[1].to_i + @ctpArr[13].to_i
    @tmp_array[2] = @tmp_array[2].to_i + 0
    @tmp_array[3] = @tmp_array[3].to_i + @podArr[1].to_i
    @tmp_array[4] = 0
    @tmp_array[5] = 0
    @tmp_array[6] = @tmp_array[6].to_i + @gaicyuArr[1].to_i
    @tmp_array[7] = 0
    @tmp_array[8] = @tmp_array[8].to_i + @hassoArr[9].to_i
    @tmp_array[9] = 0

    @mitumori_array[0] = @mitumori_array[0].to_i + @papers[0].to_i
    @mitumori_array[1] = @mitumori_array[1].to_i + @ctpArr[0].to_i
    @mitumori_array[2] = @mitumori_array[2].to_i + @pressArr[0]
    @mitumori_array[3] = @mitumori_array[3].to_i + @podArr[0].to_i
    @mitumori_array[4] = @mitumori_array[4].to_i + @kakoArr[0].to_i
    @mitumori_array[5] = @mitumori_array[5].to_i + @seisakuArr[0].to_i
    @mitumori_array[6] = @mitumori_array[6].to_i + @gaicyuArr[0].to_i
    @mitumori_array[7] = @mitumori_array[7].to_i + @assemblyArr[0].to_i
    @mitumori_array[8] = @mitumori_array[8].to_i + @hassoArr[0].to_i
    @mitumori_array[9] = @mitumori_array[9].to_i + @keihiArr[0].to_i

    @roumu_array[0] = @roumu_array[0].to_f + @papers[17].to_f
    @roumu_array[1] = @roumu_array[1].to_f + @ctpArr[12].to_f
    @roumu_array[2] = @roumu_array[2].to_f + @pressArr[8].to_f
    @roumu_array[3] = @roumu_array[3].to_f + @podArr[9].to_f
    @roumu_array[4] = @roumu_array[4].to_f + @kakoArr[9].to_f
    @roumu_array[5] = @roumu_array[5].to_f + @seisakuArr[8].to_f
    @roumu_array[6] = @roumu_array[6].to_f + @seisakuArr[9].to_f
    @roumu_array[7] = @roumu_array[7].to_f + @hassoArr[8].to_f # 7配送
    @roumu_array[8] = @roumu_array[8].to_f + @assemblyArr[5].to_f #

    add_datum = AddDatum.find_by(job_id: job)

    @sale_sum += value_cal_price_helper(job,add_datum)

    @mission_array[18] = @mission_array[18].to_i + safe_i(@sale_sum)

    if job.info.textInfo02&.include?("オフ輪")
      @mission_array[1] = @mission_array[1].to_i + @sale_sum #印刷費基準値オフ輪転
      @mission_array[0] = @mission_array[0].to_i + safe_i(@papers[1]) #用紙オフ輪転
      @mission_array[13] = @mission_array[13].to_i + safe_i(@ctpArr[13]) #刷版
    end
    if job.info.textInfo02&.include?("オフセット")
      @mission_array[2] = @mission_array[2].to_i + @sale_sum #印刷費基準値枚葉
      @mission_array[11] = @mission_array[11].to_i + safe_i(@papers[1]) #用紙枚葉
      @mission_array[17] = @mission_array[17].to_i + safe_i(@ctpArr[13]) #刷版
    end
    puts "@papers[1].to_i #{@papers[1].to_i} @mission_array[1] #{@mission_array[1].to_i}"
    @mission_array[3] = @roumu_array[0].to_f + @roumu_array[1].to_f + @roumu_array[2].to_f + @roumu_array[3].to_f + @roumu_array[4].to_f + @roumu_array[7].to_f #製造労務時間
    @mission_array[4] = (@mission_array[3].to_f * @unit_price.d27).to_i
    @mission_array[5] = @roumu_array[5].to_f #制作労務時間
    @mission_array[6] = (@mission_array[5].to_f * @unit_price.d25).to_i
    @mission_array[7] = @roumu_array[6].to_f #デザイン労務時間
    @mission_array[8] = (@mission_array[7].to_f * @unit_price.d26).to_i
    @mission_array[9] = @roumu_array[8].to_f #アセンブリ労務時間
    @mission_array[10] = (@mission_array[9].to_f * @unit_price.d29).to_i
    if job.info.textInfo02&.include?("外注") && ((@mission_array[4]).to_i + (@mission_array[6]).to_i + (@mission_array[8]).to_i + (@mission_array[10]).to_i) == 0
      @mission_array[12] = @mission_array[12].to_i + @sale_sum.to_i #全外注 #全外注
    end
    @mission_array[14] = @mission_array[14].to_i + @podArr[10] # POD原価
    @mission_array[41] = @mission_array[41].to_i + (@roumu_array[4].to_f * @unit_price.d27).to_i #加工労務費
    @mission_array[42] = @mission_array[42].to_i +  @ctpArr[12] # 1製版労務費
    @mission_array[43] = @mission_array[43].to_i +  @papers[17] # 1ロールカッター労務費
    @mission_array[45] = @mission_array[45].to_i +  (@pressArr[8].to_f * @unit_price.d27).to_i # 1印刷労務費
    @mission_array[46] = @mission_array[46].to_i +  (@podArr[9].to_f * @unit_price.d27).to_i # 1POD労務費
    @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
    @mission_array[35] = @mission_array[35].to_i + safe_i(@hassoArr[9])
    @mission_array[40] = sales_code_helper(job.sale_id)
  end

  def work_data_out

  end
end
