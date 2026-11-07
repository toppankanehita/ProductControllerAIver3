# == Schema Information
#
# Table name: WorkSlip.jobs
#
#  id           :integer          not null, primary key
#  name         :string(255)      default("新規")
#  change_no    :integer
#  sale_id      :integer
#  matter_id    :integer
#  customer_id  :integer
#  info_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  den_id       :string(64)
#  update_at    :datetime
#  create0_frag :integer
#  change0_frag :integer
#  create1_frag :integer
#  change1_frag :integer
#  create2_frag :integer          unsigned
#  change2_frag :integer
#  task_id      :integer
#  complete     :integer          default(0)
#  life         :integer          default(2)
#
class Job < WorkModel
  include JobExtensions
  self.table_name = "WorkSlip.jobs"

  belongs_to :info
  has_many :infos
  has_many :calendars
  has_many :cpr_jobs
  has_many :chktimes

  has_many :works,-> {where lastest:1}
  has_many :tasks
  has_many :cargos
  has_many :add_values
  has_many :add_presses
  has_one :add_datum
  has_many :slips
  has_many :impositions
  has_one :uploadfile
  has_many :reporttimes
  has_many :reportitems
  has_many :sales
  has_many :outsource_orders



  def self.ransack(params = nil, options = {})
    if params.present?
      raw = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h.dup : params.to_h.dup
      sale_gteq = raw["sales_sale_day_gteq"].presence || raw[:sales_sale_day_gteq].presence
      sale_lteq = raw["sales_sale_day_lteq"].presence || raw[:sales_sale_day_lteq].presence

      if (sale_gteq.present? || sale_lteq.present?) && !raw.key?("id_in") && !raw.key?(:id_in)
        sales_params = {}
        sales_params[:sale_day_gteq] = sale_gteq if sale_gteq.present?
        sales_params[:sale_day_lteq] = sale_lteq if sale_lteq.present?
        job_ids = Sale.ransack(sales_params).result.pluck(:job_id).compact.uniq
        raw["id_in"] = job_ids.present? ? job_ids : [0]
      end

      raw.delete("sales_sale_day_gteq")
      raw.delete("sales_sale_day_lteq")
      raw.delete(:sales_sale_day_gteq)
      raw.delete(:sales_sale_day_lteq)
      super(raw, options)
    else
      super(params, options)
    end
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end
  def self.ransackable_attributes(auth_object = nil)
    column_names + _ransackers.keys
  end

  def self.table_name_prefix
    "WorkSlip."
  end
end
