module JobsHelper

  def size_helper( t , y)
    if t.present? && y.present?
      return raw("#{t}<span>mm</span> ☓ #{y}<span>mm</span>")
    elsif t.blank? && y.blank?
      return ""
    else
      return raw("#{t}#{y}<span>mm</span>")
    end
  end

  def book_helper_wrap(job)
    info = job.info
    r = ""
    r = book_helper4( info.numInfo08.to_i , info.numInfo09.to_i )
    return  raw(r)
  end
  def color_helper(h1, h2 ,u1, u2, textInfo02)
    r_txt = ""
    p_txt = 1
    if h1.present?
      r_txt << "#{process(h1)} "
    end

    if h2.present?
      r_txt << "#{h2} "
      if h2 > 0 && h1 != 1
        p_txt = 0
      end
    end
    if u1.present?
      if h2.blank?
        r_txt << "0 "
      end
      r_txt << "☓ #{u1}"

    else
      if h2.present?
        r_txt << "☓ 0"
      end
    end
    if u2.present?
      r_txt << " #{process(u2)}"
      if u2 > 0 && u2 != 1
        p_txt = 0
      end
    end
    if p_txt == 0 && (textInfo02 == "002　オフセット" || textInfo02 == "003　オフ輪")
      r_txt << "<span class='sp_color'>特色</span>"
    end
    return raw(r_txt)
  end
  def process(p)
    if p == 1 then
      return "プロセス"
    end
  end
  def num_hepler(info)
    r_txt = ""
    @print_num = 0
    if info.numInfo01.present? && info.numInfo01 != 0
      r_txt << "#{info.numInfo01.to_fs(:delimited)} <span>#{ info.textInfo29 }</span> "
      if info.textInfo29.index("箱") && info.textInfo07.index("名刺")
        @print_num += (info.numInfo01 * 100)
      else
        @print_num += info.numInfo01
      end

    end
    if info.numInfo02.present? && info.numInfo02 != 0
      r_txt << "【#{info.textInfo09}】#{info.numInfo02.to_fs(:delimited)} <span>#{ info.textInfo30 }</span> "
      @print_num += info.numInfo02
    end
    if info.numInfo03.present? && info.numInfo03 != 0
      r_txt << "【#{info.textInfo10}】#{info.numInfo03.to_fs(:delimited)} <span>#{ info.textInfo31 }</span>"
      @print_num += info.numInfo03
    end
    return raw(r_txt)
  end
  def num_hepler2(info)
    r_txt = ""
    @print_num = 0
    if info.numInfo01.present? && info.numInfo01 != 0
      r_txt << "#{info.numInfo01.to_fs(:delimited)} <span>#{ info.textInfo29 }</span> "
      if info.textInfo29.index("箱") && info.textInfo07.index("名刺")
        @print_num += (info.numInfo01 * 100)
      else
        @print_num += info.numInfo01
      end
    end
    if info.numInfo02.present? && info.numInfo02 != 0
      if r_txt == ""
        r_txt << "#{info.numInfo02.to_fs(:delimited)} <span>#{ info.textInfo30 }</span> "
      else
        r_txt << "<br> #{info.numInfo02.to_fs(:delimited)} <span>#{ info.textInfo30 }</span> "
      end
      @print_num += info.numInfo02
    end
    if info.numInfo03.present? && info.numInfo03 != 0
      if r_txt == ""
        r_txt << "#{info.numInfo03.to_fs(:delimited)} <span>#{ info.textInfo31 }</span>"
      else
        r_txt << "<br> #{info.numInfo03.to_fs(:delimited)} <span>#{ info.textInfo31 }</span>"
      end

      @print_num += info.numInfo03
    end
    return raw(r_txt)
  end
  def denpyo_no(job)
    name = job.name
    if job.info.hold == 1
      name = "保留"
    end
    if job.info.cansel == 1
      name = "キャンセル"
    end
    return "#{name}#{job.change_no == 0 ? "" : job.change_no} "
  end
  def linebreaksbr(text)
    if text.blank?
      return ""
    else
      fmv = 11.chr#ファイルメーカーで使っている改行
      text = text.gsub(/\r\n|\r|\n/, "<br />")
      text = text.gsub(fmv, "<br />")
      return raw(text)
    end
  end
  def linebreaks(text)
    if text.blank?
      return ""
    else
      fmv = 11.chr#ファイルメーカーで使っている改行
      text = text.gsub(/\r\n|\r|\n/, "")
      text = text.gsub(fmv, "")
      return raw(text)
    end
  end

  def ctp_helper(job)
    #if @slips.present?
    #rimps = []
    slips = Slip.where(job_id: job)
    r = ""
    slips.each do |slip|
      imps = Imposition.where(slip_id: slip)

      imps.each do |imp|
        if imp.machine == "XL106" || imp.machine == "SM74"
          #rimps.push(imp)
          if slip.numInfo03 > 0
            r = r + (r.blank? ? "" : "<br>")
            r << print_imp(imp,slip) << "#{slip.numInfo03}枚"
          end
        elsif job.info.textInfo02.index("オフ輪")
          #rimps.push(imp)
          if slip.numInfo03 > 0
            r = r + (r.blank? ? "" : "<br>")
            r << print_imp(imp,slip) << "#{slip.numInfo03}枚"
          end
        elsif job.info.textInfo02 == "プリント出力" && imp.machine == "プリント" then
          if slip.color_print > 0 || slip.mono_print > 0 || slip.sp_print > 0
            #rimps.push(imp)

              r = r + (r.blank? ? "" : "<br>")
              r << print_imp(imp,slip)

          end
        end
      end
    end
    #return rimps
    return raw(r)
  end

  def print_imp(imp,slip)
    r = ""
    r = r + (slip.dateInfo02.present? ? hiduke3_helper(slip.dateInfo02) + " " : "")
    r = r + (imp.machine.present? ? imp.machine + " " : "")
    r = r + (imp.num.present? ? "#{imp.num}面 " : "")
    r = r + (imp.dai.present? ? "#{imp.dai}台 " : "")

    return r
  end
  def value_check_helper(value)
    job = value.job
    last = AddValue.where(job_id: job).last
    if last == value || last.nil?
     return true
    else
      return false
    end
  end
  def mount_chk_helper
    is_mac = RUBY_PLATFORM.include?("darwin")

    if is_mac
      # 2. サーバーのVolume "www" がマウントされているか調べる
      # macOSでは通常 /Volumes/ボリューム名 にマウントされます
      target_volume = "/Volumes/www"

      if File.directory?(target_volume)
        # mountコマンドの結果を確認して、本当にマウントポイントかチェックする（より確実な方法）
        mounted = `mount`.include?(target_volume)

        if mounted
          puts "ボリューム '#{target_volume}' は正常にマウントされています。"
          return true
        else
          puts "ディレクトリは存在しますが、マウントはされていないようです。"
          return false
        end
      else
        puts "ボリューム '#{target_volume}' は見つかりません（マウントされていません）。"
        return false
      end

    else
      puts "このOSは Mac ではありません (#{RUBY_PLATFORM})。"
      return false
    end
  end
end
