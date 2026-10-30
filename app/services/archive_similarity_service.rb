# frozen_string_literal: true

# MySQL 5.7 環境でも使える簡易ベクトル類似度（n-gram + コサイン類似度）
# - 日本語も扱えるよう、スペース分割に頼らず文字 n-gram を使用
# - 速度配慮: プールは controller 側である程度 limit/order して渡すこと
class ArchiveSimilarityService
  DEFAULT_N = 3

  def initialize(n: DEFAULT_N)
    @n = n
  end

  # query_text: 検索基準テキスト
  # pool: ActiveRecord::Relation または Enumerable（Archive レコード群）
  # top_k: 返す件数
  # include_attributes: 返却する attributes のホワイトリスト（nil の場合は文字列/数値のみ返却）
  def top_similar(query_text, pool:, top_k: 3, include_attributes: nil)
    q_norm = normalize(query_text.to_s)
    q_vec  = vectorize(q_norm)

    results = []
    pool.each do |rec|
      rec_text = record_text(rec)
      next if rec_text.blank?

      sim = similarity(q_vec, vectorize(normalize(rec_text)))
      next if sim <= 0.0

      attrs =
        if include_attributes
          rec.attributes.slice(*include_attributes.map(&:to_s)) rescue {}
        else
          # 文字列/数値のみ返す（そのままフォームに流し込みやすい）
          rec.attributes.select { |_k, v| v.is_a?(String) || v.is_a?(Numeric) }
        end

      results << { id: rec.id, score: sim, attributes: attrs }
    end

    results.sort_by { |h| -h[:score] }.first(top_k)
  end

  private

  def record_text(rec)
    if rec.respond_to?(:search_blob)
      rec.search_blob
    else
      # 万一拡張が未ロードでも最低限のテキスト生成
      string_cols = rec.class.columns_hash.select { |_n, c| [:string, :text].include?(c.type) }.keys
      rec.attributes.slice(*string_cols).values.compact.join(" ")
    end
  rescue StandardError
    ""
  end

  def normalize(text)
    t = text.to_s
    # NFKC 正規化 + 小文字 + 制御/余分な空白の整理
    t = t.unicode_normalize(:nfkc).downcase
    t.gsub(/[^\p{Alnum}\p{Han}\p{Hiragana}\p{Katakana}]+/u, " ").squeeze(" ").strip
  end

  def vectorize(text)
    grams(text, @n).tally
  end

  # 文字 n-gram 抽出（英数連続は単語も1語として含める）
  def grams(text, n)
    chars = text.each_char.to_a
    res = []
    # n-gram
    if chars.length >= n
      (0..(chars.length - n)).each { |i| res << chars[i, n].join }
    else
      res << chars.join
    end
    # 追加で英数字単語も特徴量に
    text.scan(/[a-z0-9]+/i).each { |w| res << w }
    res
  end

  def similarity(v1, v2)
    return 0.0 if v1.empty? || v2.empty?

    dot = 0.0
    v1.each do |k, v|
      vv = v2[k]
      dot += v * vv if vv
    end
    n1 = Math.sqrt(v1.values.sum { |x| x * x })
    n2 = Math.sqrt(v2.values.sum { |x| x * x })
    return 0.0 if n1.zero? || n2.zero?

    dot / (n1 * n2)
  end
end
