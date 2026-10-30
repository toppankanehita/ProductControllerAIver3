# frozen_string_literal: true

class SuggestionsController < ApplicationController
  # GET /suggestions/archives.json?add_value_id=:id or ?q=free text
  def archives
    query_text = params[:q].to_s
    if params[:add_value_id].present?
      av = AddValue.find_by(id: params[:add_value_id])
      if av
        av_blob = av.respond_to?(:search_blob) ? av.search_blob : safe_blob_from_record(av)
        query_text = [query_text, av_blob].compact.join(" ").strip
        if av.respond_to?(:job) && av.job
          # Job の情報も類似度に寄与させる（job.info も優先的に含める）
          job_blob =
            if av.job.respond_to?(:search_blob)
              av.job.search_blob
            else
              safe_blob_from_record(av.job)
            end
          query_text = [query_text, job_blob].compact.join(" ").strip

          # 詳細情報（job.info）は精度向上のため重み付けして反映
          if av.job.respond_to?(:info) && av.job.info.present?
            job_info_text = stringify_info(av.job.info)
            query_text = [query_text, job_info_text, job_info_text].compact.join(" ").strip

            # 類似のArchiveを検索する際の項目の重要度を反映
            important_w = 6  # 最重要
            heaviest_w  = 9  # 最重
            ti05   = extract_job_info_field(av.job.info, 'textInfo05')
            ti07   = extract_job_info_field(av.job.info, 'textInfo07')
            ti11   = extract_job_info_field(av.job.info, 'textInfo11')
            ni01   = extract_job_info_field(av.job.info, 'numInfo01')
            psize  = extract_job_info_field(av.job.info, 'press_size')
            ni06  = extract_job_info_field(av.job.info, 'numInfo06')
            ni07  = extract_job_info_field(av.job.info, 'numInfo07')
            ni14  = extract_job_info_field(av.job.info, 'numInfo14')
            ni15  = extract_job_info_field(av.job.info, 'numInfo15')
            pcolor = extract_job_info_field(av.job.info, 'press_color')

            query_text = [
              query_text,
              repeat_weight(ti11, important_w),
              repeat_weight(ni01, important_w),
              repeat_weight(ti05, heaviest_w),
              repeat_weight(ti07, heaviest_w),

              repeat_weight(psize, heaviest_w),
              repeat_weight(ni06, heaviest_w),
              repeat_weight(ni07, heaviest_w),
              repeat_weight(ni14, heaviest_w),
              repeat_weight(ni15, heaviest_w),
              repeat_weight(pcolor, heaviest_w)
            ].compact.join(" ").strip
          end
        end
      end
    end

    # 負荷軽減のため、更新が新しい順に 2000 件をプール対象に
    info02 = map_textinfo02_for_archive(av.job.info.textInfo02)

    pool = Archive.where(textInfo02: info02 )
                  .where.not(den_id: av.den_code)
                  .where.not("ktanka < ? AND mtanka < ?",1,1)
                  .order(updated_at: :desc)
                  .limit((params[:pool_limit] || 2000).to_i)

    service = ArchiveSimilarityService.new
    @matches = service.top_similar(query_text, pool: pool, top_k: 3)

    respond_to do |format|
      format.json # app/views/suggestions/archives.json.jbuilder
      format.any { render json: @matches }
    end
  end

  private

# job.info から key の値を安全に取り出す（Hash/オブジェクト/[]対応）
def extract_job_info_field(info, key)
  case info
  when Hash
    info[key] || info[key.to_sym]
  else
    if info.respond_to?(key)
      info.public_send(key)
    elsif info.respond_to?(:[])
      info[key] || info[key.to_sym]
    else
      nil
    end
  end
rescue StandardError
  nil
end

# info.textInfo02 を Archive.textInfo02 用にマップする
# 002/003 のみ Archive 側はコード無し（「オフセット」「オフ輪」）になる点に注意
def map_textinfo02_for_archive(val)
  return nil if val.blank?
  raw = val.to_s
  norm = raw.tr("\u3000", ' ').strip # 全角スペース→半角スペース
  if norm.start_with?('002')
    'オフセット'
  elsif norm.start_with?('003')
    'オフ輪'
  else
    # それ以外は同一の値で一致する（例：'005　その他'、'用紙' 等）
    raw
  end
end

  # job.info が String/Array/Hash 等でも安全に連結して文字列化する
  def stringify_info(info)
    case info
    when nil
      ""
    when String
      info
    when Array
      info.map { |v| stringify_info(v) }.join(" ")
    when Hash
      info.values.map { |v| stringify_info(v) }.join(" ")
    else
      info.to_s
    end
  end

  # 値を指定回数繰り返してスペース区切りで結合（重み付け用）
  def repeat_weight(val, times)
    return nil if val.blank? || times.to_i <= 0
    Array.new(times.to_i) { val.to_s }.join(" ")
  end

  def safe_blob_from_record(rec)
    string_cols = rec.class.columns_hash.select { |_n, c| [:string, :text].include?(c.type) }.keys
    rec.attributes.slice(*string_cols).values.compact.join(" ")
  rescue StandardError
    ""
  end
end
