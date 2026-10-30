class CreateMissionArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :mission_archives do |t|
      t.integer :mission_archive_00
      t.string :mission_archive_01
      t.string :mission_archive_02
      t.string :mission_archive_03
      t.string :mission_archive_04
      t.string :mission_archive_05
      t.string :mission_archive_06
      t.decimal :mission_archive_07
      t.decimal :mission_archive_08
      t.decimal :mission_archive_09
      t.decimal :mission_archive_10
      t.decimal :mission_archive_11
      t.decimal :mission_archive_12
      t.float :mission_archive_13
      t.decimal :mission_archive_14
      t.decimal :mission_archive_15
      t.float :mission_archive_16
      t.decimal :mission_archive_17
      t.decimal :mission_archive_18
      t.float :mission_archive_19
      t.decimal :mission_archive_20
      t.decimal :mission_archive_21
      t.decimal :mission_archive_22
      t.decimal :mission_archive_23
      t.decimal :mission_archive_24
      t.decimal :mission_archive_25
      t.decimal :mission_archive_26
      t.decimal :mission_archive_27
      t.decimal :mission_archive_28
      t.decimal :mission_archive_29
      t.decimal :mission_archive_30
      t.decimal :mission_archive_31
      t.decimal :mission_archive_32
      t.decimal :mission_archive_33
      t.decimal :mission_archive_34
      t.decimal :mission_archive_35
      t.decimal :mission_archive_36
      t.decimal :mission_archive_37
      t.decimal :mission_archive_38
      t.decimal :mission_archive_39
      t.decimal :mission_archive_40
      t.decimal :mission_archive_41
      t.decimal :mission_archive_42
      t.decimal :mission_archive_43
      t.decimal :mission_archive_44
      t.decimal :mission_archive_45
      t.float :mission_archive_46
      t.string :target_month
      t.integer :job_id

      t.timestamps
    end
  end
end
