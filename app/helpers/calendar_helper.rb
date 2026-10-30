module CalendarHelper
  def cal_color_helper(info)
    if info.textInfo02.index("オフセット")
      return "blue"
    elsif info.textInfo02.index("オフ輪")
      return "red"
    elsif info.textInfo02 == "プリント出力"
      return "green"
    end
  end

  def touroku_helper(job)
    return "" if job.nil?

    num = AddValue
            .where(job_id: job.id)
            .where(AddValue.arel_table[:paper_price].gt(0))
            .pluck('SUM(press_num)' , 'SUM(paper_price)')
            .first
    if num[0].to_i == 0
      archive = Archive.find_by(job_id: job.id)
      if archive.present?
        num = [archive.paper_jisu.to_i + archive.paper_yobi.to_i , archive.cost_paper.to_i ]
      else
        num = [0,0]
      end
    end
    if num.count > 0
      return num
    else
      return ""
    end
  end

  def shortname(name)
    name = name.sub(/株式会社/,"")
    name = name.sub(/有限会社/,"")
    name = name.sub(/（株）/,"")
    name = name.sub(/\(株\)/,"")
    name = name.sub(/（有）/,"")
    name = name.gsub(/ /,"　")
    name = name.gsub(/　　/," ")
    name = name.gsub(/　/," ")
    name = name.strip
    return name
  rescue
    return ""
  end

end
