class WorkDatum < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "job_id", "mission_archive_00", "mission_archive_01", "mission_archive_02", "mission_archive_03", "mission_archive_04", "mission_archive_05", "mission_archive_06", "mission_archive_07", "mission_archive_08", "mission_archive_09", "mission_archive_10", "mission_archive_11", "mission_archive_12", "mission_archive_13", "mission_archive_14", "mission_archive_15", "mission_archive_16", "mission_archive_17", "mission_archive_18", "mission_archive_19", "mission_archive_20", "mission_archive_21", "mission_archive_22", "mission_archive_23", "mission_archive_24", "mission_archive_25", "mission_archive_26", "mission_archive_27", "mission_archive_28", "mission_archive_29", "mission_archive_30", "mission_archive_31", "mission_archive_32", "mission_archive_33", "mission_archive_34", "mission_archive_35", "mission_archive_36", "mission_archive_37", "mission_archive_38", "mission_archive_39", "mission_archive_40", "mission_archive_41", "mission_archive_42", "mission_archive_43", "mission_archive_44", "mission_archive_45", "mission_archive_46", "target_month", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
