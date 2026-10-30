class Archive < ApplicationRecord
  include ArchiveExtensions
  belongs_to :job
  def self.ransackable_attributes(auth_object = nil)
    ["arari", "child_job", "cost_assembly", "cost_ctp", "cost_gaicyu", "cost_haiso", "cost_kako", "cost_keihi", "cost_paper", "cost_pod", "cost_press", "cost_seisaku", "cost_sum", "created_at", "den_id", "finish_date", "id", "job_id", "ktanka", "mtanka", "numInfo01", "numInfo02", "numInfo03", "paper_jisu", "paper_ren", "paper_sasi", "paper_split", "paper_weight", "paper_yobi", "parent_job", "press_color", "press_date", "press_kaleido", "press_num", "press_size", "press_special", "press_upo", "sale_date", "sale_paper", "sale_press", "sale_sum", "sales_name", "textInfo02", "textInfo05", "textInfo07", "textInfo11", "updated_at" , "cal_paper"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["job"]
  end

end
