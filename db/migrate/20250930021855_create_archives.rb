class CreateArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :archives do |t|
      t.string :textInfo02
      t.string :den_id
      t.string :textInfo05
      t.string :textInfo07
      t.integer :numInfo01,default: 0
      t.integer :numInfo02,default: 0
      t.integer :numInfo03,default: 0
      t.date :press_date
      t.date :finish_date
      t.date :sale_date
      t.string :press_size
      t.string :press_color
      t.string :press_special
      t.string :press_upo
      t.string :press_kaleido
      t.string :textInfo11
      t.integer :press_num,default: 0
      t.integer :paper_jisu,default: 0
      t.integer :paper_yobi,default: 0
      t.integer :paper_split, limit: 3,default: 1
      t.decimal :paper_ren, precision: 6, scale: 2,default: 0.0
      t.integer :paper_sasi, limit: 3,default: 0
      t.decimal :ktanka, precision: 6, scale: 2,default: 0.0
      t.decimal :mtanka, precision: 6, scale: 2,default: 0.0
      t.decimal :paper_weight, precision: 8, scale: 2,default: 0.0
      t.decimal :sale_paper, precision: 11, scale: 2,default: 0.0
      t.decimal :sale_press, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_paper, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_ctp, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_press, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_pod, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_kako, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_seisaku, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_gaicyu, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_assembly, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_haiso, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_keihi, precision: 11, scale: 2,default: 0.0
      t.decimal :cost_sum, precision: 11, scale: 2,default: 0.0
      t.decimal :sale_sum, precision: 11, scale: 2,default: 0.0
      t.decimal :arari, precision: 11, scale: 2,default: 0.0
      t.string :parent_job
      t.string :child_job
      t.string :sales_name
      t.integer :job_id

      t.timestamps
    end
  end
end
