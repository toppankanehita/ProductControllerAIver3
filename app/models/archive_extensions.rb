# frozen_string_literal: true

# Archive モデルの機能拡張を提供するモジュール
# Zeitwerk の規約に合わせ、ファイル名 archive_extensions.rb に対して
# 定数 ArchiveExtensions を定義する
module ArchiveExtensions
  extend ActiveSupport::Concern

  class_methods do
    # 文字列/テキスト系のカラム名一覧を返す
    def searchable_columns
      columns_hash
        .select { |_name, col| [:string, :text].include?(col.type) }
        .keys
    rescue StandardError
      # 万一 columns_hash が未定義など例外時は安全側で空配列
      []
    end
  end

  # 検索用に連結したテキストを作る（nil は除外）
  def search_blob
    self.class.searchable_columns.map { |c| self[c] }.compact.join(" ")
  end
end

Rails.application.config.to_prepare do
  Archive.include(ArchiveExtensions) if defined?(Archive)
end
