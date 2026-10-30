# frozen_string_literal: true

# 既存の AddValue モデルにメソッドを追加するための拡張。
# Zeitwerk の命名規約に従い、このファイルでは AddValueExtensions 定数を定義します。
module AddValueExtensions
  extend ActiveSupport::Concern

  class_methods do
    def searchable_columns
      columns_hash
        .select { |_name, col| [:string, :text].include?(col.type) }
        .keys
    rescue StandardError
      []
    end
  end

  def search_blob
    self.class.searchable_columns.map { |c| self[c] }.compact.join(" ")
  end
end

# AddValue が読み込まれたタイミングでこの拡張を取り込む
Rails.application.config.to_prepare do
  AddValue.include(AddValueExtensions) if defined?(AddValue)
end
