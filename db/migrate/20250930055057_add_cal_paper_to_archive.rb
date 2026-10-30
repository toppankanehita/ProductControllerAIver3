class AddCalPaperToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :cal_paper, :float
    add_column :archives, :cal_press, :float
    add_column :archives, :cal_ctp, :float
    add_column :archives, :cal_pod, :float
    add_column :archives, :cal_kako, :float
    add_column :archives, :cal_seisaku, :float
    add_column :archives, :cal_gaicyu, :float
    add_column :archives, :cal_assembly, :float
    add_column :archives, :cal_haiso, :float
  end
end
