module AddValuesHelper


  def web_jisu_value(info)
    print_num = 0
    if info.numInfo01.present? && info.numInfo01 != 0
      print_num += info.numInfo01
    end
    if info.numInfo02.present? && info.numInfo02 != 0
      print_num += info.numInfo02
    end
    if info.numInfo03.present? && info.numInfo03 != 0
      print_num += info.numInfo03
    end
    wari = select_size_web[info&.textInfo20].to_i
    #puts "wari = #{wari}"

    if wari == 0
      return [print_num, 1]
    else
      return [(print_num/wari.to_i).to_i, wari]
    end

  end

  def web_yobi_value(jisu, sasi)
    #差し替え1回につき4000枚
    if jisu < 9999
      # 条件1: jisuが2501未満の場合
      yobi = 6000.0 / jisu
    elsif jisu > 130000
      # 条件2: jisuが130000より大きい場合
      yobi =  (0.069 - 0.03) * Math.exp(-0.00001 * (jisu - 150000)) + 0.03
    else
      # 上記のいずれでもない場合 (jisuが2501以上130000以下)
      yobi = (0.6 - 0.07) * Math.exp(-0.00004 * (jisu - 10000)) + 0.07
    end
    return ((yobi * jisu )+ (sasi * 1500)).to_i
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
    return r_txt
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
    return r_txt
  end

  def book_helper3( h , c)
    r_txt = 0
    if h.present? && h != 0
      r_txt = r_txt + h
    end
    if c.present? && c != 0
      r_txt = r_txt + c
    end
    return r_txt == 0 ? "" : r_txt.to_s + "p"
  end

  def sheet_size_helper(info)


  end

end
