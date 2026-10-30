# == Schema Information
#
# Table name: ToppanM.holy_dates
#
#  id         :integer          unsigned, not null, primary key
#  hday       :date
#  created_at :datetime
#  updated_at :datetime
#
class HolyDate < ToppanModel
  def national_holiday?(d)
    day = HolyDate.find_by("hday = ?",d)
    if day.blank? then
      return false
    else
      return true
    end
  end

  def self.table_name_prefix
    "ToppanM."
  end
end
