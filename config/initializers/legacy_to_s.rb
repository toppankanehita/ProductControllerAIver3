# frozen_string_literal: true

# Rails 6.1 -> Rails 8.1 互換用:
# 万一 `.to_s(:delimited)` や `.to_s(:db)` 等のシンボルフォーマット引数が呼ばれた場合に `.to_fs` へ委譲する
module LegacyFormattedToS
  def to_s(format = :default, *args)
    if format.is_a?(Symbol) && format != :default && respond_to?(:to_fs)
      to_fs(format, *args)
    elsif format == :default && args.empty?
      super()
    else
      super(format, *args)
    end
  end
end

[Integer, Float, BigDecimal, Date, Time, DateTime, ActiveSupport::TimeWithZone].each do |klass|
  klass.prepend(LegacyFormattedToS)
end
