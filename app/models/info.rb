# == Schema Information
#
# Table name: WorkSlip.infos
#
#  id          :integer          not null, primary key
#  job_id      :integer
#  sale_id     :integer
#  customer_id :integer
#  calendar_id :integer
#  change_no   :integer          default(0)
#  lastest     :integer          default(2)
#  numInfo01   :integer
#  numInfo02   :integer
#  numInfo03   :integer
#  numInfo04   :integer
#  numInfo05   :integer
#  numInfo06   :integer
#  numInfo07   :integer
#  numInfo08   :integer
#  numInfo09   :integer
#  numInfo10   :integer
#  numInfo11   :integer
#  numInfo12   :integer
#  numInfo13   :integer
#  numInfo14   :integer
#  numInfo15   :integer
#  numInfo16   :integer
#  numInfo17   :integer
#  numInfo18   :integer
#  numInfo19   :integer
#  numInfo20   :integer
#  timeInfo01  :time
#  timeInfo02  :time
#  timeInfo03  :time
#  dateInfo01  :date
#  dateInfo02  :date
#  dateInfo03  :date
#  dateInfo04  :date
#  dateInfo05  :date
#  dateInfo06  :date
#  dateInfo07  :date
#  dateInfo08  :date
#  dateInfo09  :date
#  dateInfo10  :date
#  dateInfo11  :date
#  decInfo01   :decimal(10, 2)
#  decInfo02   :decimal(10, 2)
#  decInfo03   :decimal(10, 2)
#  decInfo04   :decimal(10, 2)
#  decInfo05   :decimal(10, 2)
#  decInfo06   :decimal(10, 2)
#  decInfo07   :decimal(10, 2)
#  decInfo08   :decimal(10, 2)
#  decInfo09   :decimal(10, 2)
#  decInfo10   :decimal(10, 2)
#  textInfo01  :string(255)
#  textInfo02  :string(255)
#  textInfo03  :string(255)
#  textInfo04  :string(255)
#  textInfo05  :string(255)
#  textInfo06  :string(255)
#  textInfo07  :string(255)
#  textInfo08  :string(255)      default("印刷代金")
#  textInfo09  :string(255)
#  textInfo10  :string(255)
#  textInfo11  :string(255)
#  textInfo12  :string(255)
#  textInfo13  :string(255)
#  textInfo14  :string(255)
#  textInfo15  :string(255)
#  textInfo16  :string(255)
#  textInfo17  :string(255)
#  textInfo18  :string(255)
#  textInfo19  :string(255)
#  textInfo20  :string(255)
#  textInfo21  :string(255)
#  textInfo22  :string(255)
#  textInfo23  :string(255)
#  textInfo24  :string(255)
#  textInfo25  :string(255)
#  textInfo26  :string(255)
#  textInfo27  :string(255)
#  textInfo28  :string(511)
#  textInfo29  :string(255)
#  textInfo30  :string(255)
#  textInfo31  :string(255)
#  textInfo32  :string(255)      default("1校")
#  textInfo33  :string(255)      default("2校")
#  textInfo34  :string(255)
#  textInfo35  :string(255)      default("TOM")
#  textInfo36  :string(255)
#  textInfo37  :string(255)
#  textInfo38  :string(255)
#  textInfo39  :string(255)
#  textInfo40  :string(255)
#  textInfo41  :string(255)
#  textInfo42  :string(255)
#  textInfo43  :string(255)
#  textInfo44  :string(255)
#  textInfo45  :string(255)
#  updated_at  :datetime
#  update_at   :datetime
#  created_at  :datetime
#  copydenid   :string(64)
#  salesname   :string(32)
#  cansel      :integer          default(0)
#  hold        :integer          default(0)
#
class Info < WorkModel
  self.table_name = "WorkSlip.infos"

  belongs_to :job
  has_one :diff
  has_many :calendars
  has_one :calendar
  has_many :sasis
  has_many :works, -> { where(lastest: 1) }
  has_many :chkschedules
  has_many :sales


  def self.ransackable_attributes(auth_object = nil)
    ["calendar_id", "cansel", "change_no", "copydenid", "created_at", "customer_id", "dateInfo01", "dateInfo02", "dateInfo03", "dateInfo04", "dateInfo05", "dateInfo06", "dateInfo07", "dateInfo08", "dateInfo09", "dateInfo10", "dateInfo11", "decInfo01", "decInfo02", "decInfo03", "decInfo04", "decInfo05", "decInfo06", "decInfo07", "decInfo08", "decInfo09", "decInfo10", "hold", "id", "job_id", "lastest", "numInfo01", "numInfo02", "numInfo03", "numInfo04", "numInfo05", "numInfo06", "numInfo07", "numInfo08", "numInfo09", "numInfo10", "numInfo11", "numInfo12", "numInfo13", "numInfo14", "numInfo15", "numInfo16", "numInfo17", "numInfo18", "numInfo19", "numInfo20", "sale_id", "salesname", "textInfo01", "textInfo02", "textInfo03", "textInfo04", "textInfo05", "textInfo06", "textInfo07", "textInfo08", "textInfo09", "textInfo10", "textInfo11", "textInfo12", "textInfo13", "textInfo14", "textInfo15", "textInfo16", "textInfo17", "textInfo18", "textInfo19", "textInfo20", "textInfo21", "textInfo22", "textInfo23", "textInfo24", "textInfo25", "textInfo26", "textInfo27", "textInfo28", "textInfo29", "textInfo30", "textInfo31", "textInfo32", "textInfo33", "textInfo34", "textInfo35", "textInfo36", "textInfo37", "textInfo38", "textInfo39", "textInfo40", "textInfo41", "textInfo42", "textInfo43", "textInfo44", "textInfo45", "timeInfo01", "timeInfo02", "timeInfo03", "update_at", "updated_at"]
  end

  def total_price(dec,num)
    r = 0.0
    unless dec.blank? then
      unless num.blank? then
        r = num * dec
      end
    end
    return r
  end
  def self.table_name_prefix
    "WorkSlip."
  end
end
