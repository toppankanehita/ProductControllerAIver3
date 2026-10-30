# == Schema Information
#
# Table name: cpr_infos
#
#  id              :integer          not null, primary key
#  tci_no          :string(255)
#  dInfo01         :date
#  dInfo02         :date
#  dInfo03         :date
#  dInfo04         :date
#  dInfo05         :date
#  nInfo01         :integer
#  nInfo02         :integer
#  nInfo03         :integer
#  nInfo04         :integer
#  nInfo05         :integer
#  tInfo01         :string(255)
#  tInfo02         :string(255)
#  tInfo03         :string(255)
#  tInfo04         :string(255)
#  tInfo05         :string(255)
#  tInfo06         :string(255)
#  tInfo07         :string(255)
#  tInfo08         :string(255)
#  tInfo09         :string(255)
#  tInfo10         :string(255)
#  tInfo28         :string(255)
#  tInfo50         :string(255)
#  tInfo51         :string(255)
#  tInfo52         :string(255)
#  tInfo53         :string(255)
#  tInfo54         :string(255)
#  tInfo55         :string(255)
#  invoice_require :integer
#  invoice_month   :integer          unsigned
#  status          :integer          default(0)
#  cpr_job_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  life            :integer          default(1)
#  employee_id     :integer
#  work_kind_id    :integer
#  invoice_year    :integer
#  search          :string(255)
#  den_id          :string(255)
#  sInfo05         :string(255)
#  sInfo07         :string(255)
#
class CprInfo < CprModel
  belongs_to :cpr_job
  has_many :cpr_times
end
