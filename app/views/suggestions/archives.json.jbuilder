# 除外条件: 検索元の job.den_id と Archive.en_id が同一なら対象外
den_param = params[:den_id].presence || params[:den_code].presence || params[:den].presence

matches =
  if den_param.present?
    @matches.reject do |m|
      attrs = m[:attributes] || {}
      en_id_value = (attrs[:en_id] || attrs['en_id']).to_s
      en_id_value == den_param.to_s
    end
  else
    @matches
  end

json.array! matches do |m|
  json.id    m[:id]
  json.score m[:score]

  attrs = m[:attributes] || {}

  json.attributes do
    # 既存の属性をそのまま展開
    attrs.each { |k, v|
      json.set! k, v
      #puts "k: #{k}, v: #{v}"
    }

    # ソースから値を吸い上げ（symbol/string 双方対応）
    post_press  = attrs[:post_press]   || attrs['post_press']
    paper_route = attrs[:paper_route]  || attrs['paper_route']
    paper_name  = attrs[:paper_name]   || attrs['paper_name']

    # paper_* 優先で、なければ従来キーから補完
    jisu   = attrs[:paper_jisu]    || attrs['paper_jisu']    || attrs[:jisu]   || attrs['jisu']
    yobi   = attrs[:paper_yobi]    || attrs['paper_yobi']    || attrs[:yobi]   || attrs['yobi']
    ren    = attrs[:paper_ren]     || attrs['paper_ren']     || attrs[:ren]    || attrs['ren']
    ktanka = attrs[:paper_ktanka]  || attrs['paper_ktanka']  || attrs[:ktanka] || attrs['ktanka']
    # ユーザー指定は paper_mtanaka（t の後に n がくる綴り）。従来キーは mtanka。
    mtanka = attrs[:paper_mtanka] || attrs['paper_mtanka'] || attrs[:mtanka] || attrs['mtanka']

    # 表示用に paper_* を明示
    json.post_press     post_press
    json.paper_route    paper_route
    json.paper_name     paper_name
    json.paper_jisu     jisu
    json.paper_yobi     yobi
    json.paper_ren      ren
    json.paper_ktanka   ktanka
    json.paper_mtanaka  mtanka

    # 既存 UI が従来キーを参照している場合に備えてミラーも返す
    json.jisu   jisu
    json.yobi   yobi
    json.ren    ren
    json.ktanka ktanka
    json.mtanka mtanka
  end
end
