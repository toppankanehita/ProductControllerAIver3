# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  class ActiveRecord::Base
    def self.ransackable_attributes(auth_object = nil)
      column_names + _ransackers.keys
    rescue StandardError
      []
    end

    def self.ransackable_associations(auth_object = nil)
      reflect_on_all_associations.map { |a| a.name.to_s }
    rescue StandardError
      []
    end
  end
end
