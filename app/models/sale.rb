# == Schema Information
#
# Table name: sales
#
#  id         :bigint           not null, primary key
#  t01        :string(255)
#  t02        :string(255)
#  t03        :string(255)
#  t04        :string(255)
#  t05        :string(255)
#  t06        :string(255)
#  t07        :string(255)
#  t08        :string(255)
#  t09        :string(255)
#  t10        :string(255)
#  t11        :string(255)
#  t12        :string(255)
#  d01        :decimal(10, 2)   default(0.0)
#  d02        :decimal(10, 2)   default(0.0)
#  d03        :decimal(10, 2)   default(0.0)
#  i01        :integer
#  i02        :integer
#  i03        :integer
#  i04        :integer
#  textInfo02 :string(255)
#  textInfo03 :string(255)
#  job_id     :integer
#  info_id    :integer
#  div_id     :integer
#  salescode  :integer
#  denid      :string(255)
#  sale_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sum_frag   :integer          default(0)
#  d04        :decimal(10, 2)   default(0.0)
#  sale_day   :date
#
class Sale < VisualizeModel
  has_many :sale_items, dependent: :destroy
  belongs_to :job, optional: true
  belongs_to :info, optional: true
  belongs_to :div, optional: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "d01", "d02", "d03", "d04", "denid", "div_id", "i01", "i02", "i03", "i04", "id", "info_id", "job_id", "sale_day", "sale_id", "salescode", "sum_frag", "t01", "t02", "t03", "t04", "t05", "t06", "t07", "t08", "t09", "t10", "t11", "t12", "textInfo02", "textInfo03", "updated_at"]
  end
end
