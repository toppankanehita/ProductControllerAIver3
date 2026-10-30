class AddAllCtpPlateToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_ctp_plate, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_pod_cost, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
