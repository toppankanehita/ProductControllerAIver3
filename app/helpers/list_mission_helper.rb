require 'nkf'
module ListMissionHelper
    # 単価情報/間接費標準原価割合.xlsx に基づく標準原価配賦率（調整後対象売上1円あたり）
    STANDARD_INDIRECT_RATES = {
        roumu:         0.099, # 労務費（賃金手当）
        bonus:         0.016, # 賞与（賞与手当）
        legal_welfare: 0.023, # 法定福利（法定福利費）
        utilities:     0.144, # 水道光熱費
        repair:        0.023, # 修繕費
        taxes:         0.036, # 租税公課
        insurance:     0.041, # 保険料
        supplies:      0.016, # 消耗品費
        vehicle:       0.011, # 車両費
        communication: 0.007, # 通信費
        depreciation:  0.132, # 減価償却費
        misc:          0.008  # 雑費
    }.freeze

    def mission_cal_wap
        @roumu_array = Array.new(11)

        if @cost_data.present?

        end
    end
    def mission_child_helper(job)
        #合算するJobがあれば
        @cost = Cost.find_by(target_month: session[:target_month])
        @mitumori_array = Array.new(11)
        @tmp_array = Array.new(11)
        @roumu_array = Array.new(11)
        @mission_array = Array.new(52, 0)
        @tmp_hiyou_sum = 0
        @mitumori_sum = 0
        @sale_sum = 0
        child_ids = AddDatum.where(parent_code: job.den_id)
        @child_count = 0
        @childs_den_id = []
        #puts "child_ids #{child_ids.count}"
        child_ids.each do |datum|
            arari_cal_wap(datum.job)
            @tmp_array[0] = @tmp_array[0].to_i + @papers[1].to_i
            @tmp_array[1] = @tmp_array[1].to_i + @ctpArr[13].to_i
            @tmp_array[2] = @tmp_array[2].to_i + 0
            @tmp_array[3] = @tmp_array[3].to_i + @podArr[1].to_i
            @tmp_array[4] = 0
            @tmp_array[5] = 0
            @tmp_array[6] = @tmp_array[6].to_i + @gaicyuArr[1].to_i
            @tmp_array[7] = 0
            @tmp_array[8] = @tmp_array[8].to_i + @hassoArr[9].to_i
            @tmp_array[9] = 0

            @mitumori_array[0] = @mitumori_array[0].to_i + @papers[0].to_i
            @mitumori_array[1] = @mitumori_array[1].to_i + @ctpArr[0].to_i
            @mitumori_array[2] = @mitumori_array[2].to_i + @pressArr[0]
            @mitumori_array[3] = @mitumori_array[3].to_i + @podArr[0].to_i
            @mitumori_array[4] = @mitumori_array[4].to_i + @kakoArr[0].to_i
            @mitumori_array[5] = @mitumori_array[5].to_i + @seisakuArr[0].to_i
            @mitumori_array[6] = @mitumori_array[6].to_i + @gaicyuArr[0].to_i
            @mitumori_array[7] = @mitumori_array[7].to_i + @assemblyArr[0].to_i
            @mitumori_array[8] = @mitumori_array[8].to_i + @hassoArr[0].to_i
            @mitumori_array[9] = @mitumori_array[9].to_i + @keihiArr[0].to_i

            @roumu_array[0] = @roumu_array[0].to_f + @papers[17].to_f
            @roumu_array[1] = @roumu_array[1].to_f + @ctpArr[12].to_f
            @roumu_array[2] = @roumu_array[2].to_f + @pressArr[8].to_f
            @roumu_array[3] = @roumu_array[3].to_f + @podArr[9].to_f
            @roumu_array[4] = @roumu_array[4].to_f + @kakoArr[9].to_f
            @roumu_array[5] = @roumu_array[5].to_f + @seisakuArr[8].to_f
            @roumu_array[6] = @roumu_array[6].to_f + @seisakuArr[9].to_f
            @roumu_array[7] = @roumu_array[7].to_f + @hassoArr[8].to_f # 7配送
            @roumu_array[8] = @roumu_array[8].to_f + @assemblyArr[5].to_f #
            #puts "@sale_sum #{@sale_sum}"
            add_datum = AddDatum.find_by(job_id: datum.job)
            #puts "@sale_sum #{@sale_sum}"
            @sale_sum += value_cal_price_helper(datum.job,add_datum)
            #puts "@sale_sum #{@sale_sum}"
            @mission_array[18] = safe_i(@sale_sum)

            #puts "datum.job #{datum.job.id}  job #{job.id} @mission_array[18] #{@mission_array[18]} sale #{safe_i(@sale_sum)}"
            if datum.job.info.textInfo02&.include?("オフ輪")
                @mission_array[1] = @mission_array[1].to_i + @sale_sum #印刷費基準値オフ輪転
                @mission_array[0] = @mission_array[0].to_i + safe_i(@papers[1]) #用紙オフ輪転
                @mission_array[13] = @mission_array[13].to_i + safe_i(@ctpArr[13]) #刷版
            end
            if datum.job.info.textInfo02&.include?("オフセット")
                @mission_array[2] = @mission_array[2].to_i + @sale_sum #印刷費基準値枚葉
                @mission_array[11] = @mission_array[11].to_i + safe_i(@papers[1]) #用紙枚葉
                @mission_array[17] = @mission_array[17].to_i + safe_i(@ctpArr[13]) #刷版
            end
            @mission_array[48] = @mission_array[48].to_i + safe_i(@papers[1]) #全用紙金額
            @mission_array[3] = @roumu_array[0].to_f + @roumu_array[1].to_f + @roumu_array[2].to_f + @roumu_array[3].to_f + @roumu_array[4].to_f + @roumu_array[7].to_f #製造労務時間
            @mission_array[4] = (@mission_array[3].to_f * @unit_price.d27).to_i
            @mission_array[5] = @roumu_array[5].to_f #制作労務時間
            @mission_array[6] = (@mission_array[5].to_f * @unit_price.d25).to_i
            @mission_array[7] = @roumu_array[6].to_f #デザイン労務時間
            @mission_array[8] = (@mission_array[7].to_f * @unit_price.d26).to_i
            @mission_array[9] = @roumu_array[8].to_f #アセンブリ労務時間
            @mission_array[10] = (@mission_array[9].to_f * @unit_price.d29).to_i
            if datum.job.info.textInfo02&.include?("外注") && ((@mission_array[4]).to_i + (@mission_array[6]).to_i + (@mission_array[8]).to_i + (@mission_array[10]).to_i) == 0
                @mission_array[12] = @mission_array[12].to_i + @sale_sum.to_i #全外注 #全外注
            end
            @mission_array[14] = @mission_array[14].to_i + @podArr[10] # POD原価
            @mission_array[41] = @mission_array[41].to_i + (@roumu_array[4].to_f * @unit_price.d27).to_i #加工労務費
            @mission_array[42] = @mission_array[42].to_i +  @ctpArr[12] # 1製版労務費
            @mission_array[43] = @mission_array[43].to_i +  @papers[17] # 1ロールカッター労務費
            @mission_array[45] = @mission_array[45].to_i +  (@pressArr[8].to_f * @unit_price.d27).to_i # 1印刷労務費
            @mission_array[46] = @mission_array[46].to_i +  (@podArr[9].to_f * @unit_price.d27).to_i # 1POD労務費
            # debit = Debit.find_by(job_id: datum.job.id , target_month: session[:target_month])
            # #puts "@gaicyuArr[1].to_i #{@gaicyuArr[1].to_i}"
            # if debit.blank?
            #     #何もしない
            #     add_datum = AddDatum.find_by(job_id: datum.job.id)
            #     if add_datum&.parent_code.present?
            #         parent_job = Job.find_by(den_id: add_datum.parent_code)
            #         debit = Debit.find_by(job_id: parent_job.id , target_month: session[:target_month])
            #         if debit.blank?
            #             #親コードも密彼らなかったら外注
            #             @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
            #         elsif debit.siwake == "外注"
            #             @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
            #
            #         elsif debit.siwake == "仕入"
            #             @mission_array[16] = @mission_array[16].to_i + safe_i(@gaicyuArr[1])
            #         end
            #     end
            # elsif debit.siwake == "外注"
            #     #puts "debit #{debit.name} #{debit.siwake} #{datum.job.den_id}"
            #     @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
            #
            # elsif debit.siwake == "仕入"
            #     #puts "debit #{debit.name} #{debit.siwake} #{datum.job.den_id}"
            #     @mission_array[16] = @mission_array[16].to_i + safe_i(@gaicyuArr[1])
            # else
            #     @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
            # end
            @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
            #間接費
            # if datum.job.info.textInfo02&.include?("外注") && ((@mission_array[4]).to_i + (@mission_array[6]).to_i + (@mission_array[8]).to_i + (@mission_array[10]).to_i) == 0
            #     #何も
            # else
            #     kansetu_wari = (@sale_sum.to_i - @mission_array[15].to_i - @mission_array[16].to_i).to_f / (@cost.all_slip_sales.to_i + @cost.cost23.to_i - @cost.all_outsourcing.to_i - @cost.all_out_cost.to_i - @cost.all_in_cost.to_i).to_f
            #
            #     # kansetu_wari = @sale_sum.to_f / (@cost.all_slip_sales.to_i + @cost.cost23.to_i - @cost.all_outsourcing.to_i).to_f
            #     target_roumu = @cost.cost02.to_i - (@cost.all_roumu_product.to_i + @cost.all_roumu_create.to_i + @cost.all_roumu_design.to_i + @cost.cost20.to_i) #対象労務費
            #     #puts "kansetu_wari #{kansetu_wari} / #{(@cost.all_slip_sales.to_i + @cost.cost23.to_i - @cost.all_outsourcing.to_i).to_f} target_roumu #{target_roumu}"
            #     syu_web = @cost.cost21
            #     syu_sheet = @cost.cost22
            #     syu_other = @cost.cost08 - (syu_web .to_i + syu_sheet.to_i)
            #
            #     if datum.job.info.textInfo02&.include?("オフ輪")
            #         wari = @mission_array[1] / @cost.all_press_web
            #         @mission_array[19] = @mission_array[19].to_i + safe_i(@cost.cost18 * wari) #間接費オフ輪材料費
            #         @mission_array[27] = @mission_array[27].to_i + safe_i(syu_web * wari) #間接修繕費
            #     elsif datum.job.info.textInfo02&.include?("オフセット")
            #         wari = @mission_array[2] / @cost.all_press_sheet
            #         @mission_array[20] = @mission_array[20].to_i + safe_i(@cost.cost19 * wari) #間接費枚葉材料費
            #         @mission_array[27] = @mission_array[27].to_i + safe_i(syu_sheet * wari) #間接修繕費
            #     end
            #     @mission_array[27] = @mission_array[27].to_i + safe_i(syu_other * kansetu_wari) #間接修繕費
            #     @mission_array[21] = @mission_array[21].to_i + safe_i(target_roumu * kansetu_wari) #間接費枚葉材料費
            #     @mission_array[22] = @mission_array[22].to_i + safe_i(@cost.cost03.to_i * kansetu_wari) #間接費賞与
            #     zakkyu = @cost.cost04 - @cost.all_assembly
            #     if zakkyu > 0
            #         #puts "zakkyu #{zakkyu} kansetu_wari #{kansetu_wari}"
            #         @mission_array[23] = @mission_array[23].to_i + safe_i(zakkyu * kansetu_wari)
            #     end
            #     @mission_array[24] = @mission_array[24].to_i + safe_i(@cost.cost05.to_i * kansetu_wari) #間接法定福利
            #     @mission_array[25] = @mission_array[25].to_i + safe_i(@cost.cost06.to_i * kansetu_wari) #間接福利厚生費
            #     @mission_array[26] = @mission_array[26].to_i + safe_i(@cost.cost07.to_i * kansetu_wari) #間接水道光熱費
            #     @mission_array[27] = @mission_array[27].to_i + safe_i(@cost.cost08.to_i * kansetu_wari) #間接修繕費
            #     @mission_array[28] = @mission_array[28].to_i + safe_i(@cost.cost09.to_i * kansetu_wari) #間接租税公課
            #     @mission_array[29] = @mission_array[29].to_i + safe_i(@cost.cost10.to_i * kansetu_wari) #間接賃借料
            #     @mission_array[30] = @mission_array[30].to_i + safe_i(@cost.cost11.to_i * kansetu_wari) #間接保険料
            #     @mission_array[31] = @mission_array[31].to_i + safe_i(@cost.cost12.to_i * kansetu_wari) #間接消耗品費
            #     puts "#{job.den_id} child @sale_sum #{@sale_sum} @mission_array[31] #{@mission_array[31]} @cost.cost12.to_i #{@cost.cost12.to_i } * kansetu_wari #{kansetu_wari} "
            #     @mission_array[32] = @mission_array[32].to_i + safe_i(@cost.cost13.to_i * kansetu_wari) #間接減価償却「
            #     @mission_array[33] = @mission_array[33].to_i + safe_i((@cost.cost14.to_i + @cost.cost16.to_i + @cost.cost17.to_i) * kansetu_wari) #間接雑費
            #     15.times do |i|
            #         @mission_array[34] = @mission_array[34].to_i + safe_i(@mission_array[19 + i])
            #     end
            # end
            @mission_array[35] = @mission_array[35].to_i + safe_i(@hassoArr[9])
            # @mission_array[36] = (@tmp_array[0].to_i + @tmp_array[1].to_i +  + @tmp_array[3].to_i + @mission_array[15].to_i + @mission_array[16].to_i + @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i + @mission_array[34].to_i)
            # @mission_array[37] = @mission_array[37].to_i + safe_i(@mission_array[18]) #売上
            # @mission_array[38] = (@mission_array[37].to_i - @mission_array[36].to_i) #粗利
            # @mission_array[39] = (@mission_array[38].to_f / @mission_array[37].to_f)
            # #puts "売上 #{@mission_array[37]} 総費用#{@mission_array[36]} 仕入れ#{@mission_array[15]}}"
            # @mission_array[40] = sales_code_helper(datum.job.sale_id)
            @child_count += 1
            @childs_den_id.push(datum.job.den_id)
        end
    end

    # 用途: child_helper で集計した「子ジョブ分」に、親ジョブ（引数 job 自身）の値を加算し、合算トータルを求めます。
    # 引数:
    #   job: 合算のベースとなる親 Job。
    # 役割/副作用:
    #   - 親ジョブの原価を @tmp_array[0..9] に加算します。
    #   - 親ジョブの見積を @mitumori_array[0..9] に加算します。
    #   - @tmp_hiyou_sum（原価合計の総和）と @mitumori_sum（見積合計の総和）を算出します。
    #   - 事前に child_helper(job) を呼んでおくと、子+親の合算トータルが得られます。
    # 想定される呼び出し箇所:
    #   - AddValues の一覧/CSV で、表示用の合算原価・見積・粗利などを計算する直前。
    def mission_child_plus_helper(job)
        #ベースになるJobの費用

        @tmp_array ||= Array.new(10)

        @child_count ||= 0
        arari_cal_wap(job)
        #puts "0@gaicyuArr[1].to_i #{@gaicyuArr[1].to_i}"
        @tmp_array[0] = @tmp_array[0].to_i + safe_i(@papers[1])
        @tmp_array[1] = @tmp_array[1].to_i + safe_i(@ctpArr[13])
        @tmp_array[2] = @tmp_array[2].to_i + 0
        @tmp_array[3] = @tmp_array[3].to_i + safe_i(@podArr[1])
        @tmp_array[4] = 0
        @tmp_array[5] = 0
        @tmp_array[6] = @tmp_array[6].to_i + safe_i(@gaicyuArr[1])
        @tmp_array[7] = 0
        @tmp_array[8] = @tmp_array[8].to_i + @hassoArr[9].to_i
        @tmp_array[9] = 0
        @mitumori_array[0] = @mitumori_array[0].to_i + @papers[0].to_i
        @mitumori_array[1] = @mitumori_array[1].to_i + @ctpArr[0].to_i
        @mitumori_array[2] = @mitumori_array[2].to_i + @pressArr[0]
        @mitumori_array[3] = @mitumori_array[3].to_i + @podArr[0].to_i
        @mitumori_array[4] = @mitumori_array[4].to_i + @kakoArr[0].to_i
        @mitumori_array[5] = @mitumori_array[5].to_i + @seisakuArr[0].to_i
        @mitumori_array[6] = @mitumori_array[6].to_i + @gaicyuArr[0].to_i
        @mitumori_array[7] = @mitumori_array[7].to_i + @assemblyArr[0].to_i
        @mitumori_array[8] = @mitumori_array[8].to_i + @hassoArr[0].to_i
        @mitumori_array[9] = @mitumori_array[9].to_i + @keihiArr[0].to_i

        @roumu_array[0] = @roumu_array[0].to_i + @papers[17] # 0用紙
        @roumu_array[1] = @roumu_array[1].to_i + @ctpArr[12] # 1製版
        @roumu_array[2] = @roumu_array[2].to_i + @pressArr[8] # 2印刷
        @roumu_array[3] = @roumu_array[3].to_i + @podArr[9] # 3POD
        @roumu_array[4] = @roumu_array[4].to_i + @kakoArr[9] # 4加工
        @roumu_array[5] = @roumu_array[5].to_i + @seisakuArr[8] # 5制作
        @roumu_array[6] = @roumu_array[6].to_i + @seisakuArr[9] # 6デザイン
        @roumu_array[7] = @roumu_array[7].to_i + @hassoArr[8] # 7配送
        @roumu_array[8] = @roumu_array[8].to_i + @assemblyArr[5]
        #puts "2@sale_sum #{@sale_sum}"
        add_datum = AddDatum.find_by(job_id: job.id)
        #puts "2@sale_sum #{@sale_sum}"
        @sale_sum = value_cal_price_helper(job,add_datum)
        #puts "2@sale_sum #{@sale_sum}"
        @mission_array[18] = @mission_array[18].to_i + safe_i(@sale_sum)
        #puts "@mission_array[18] #{@mission_array[18]} safe_i(@sale_sum) #{safe_i(@sale_sum)}"


        if job.info.textInfo02&.include?("オフ輪")
            @mission_array[1] = @mission_array[1].to_i + @sale_sum #印刷費基準値オフ輪転
            @mission_array[0] = @mission_array[0].to_i + safe_i(@papers[1]) #用紙オフ輪転
            @mission_array[13] = @mission_array[13].to_i + safe_i(@ctpArr[13]) #刷版
        elsif job.info.textInfo02&.include?("オフセット")
            @mission_array[2] = @mission_array[2].to_i + @sale_sum #印刷費基準値枚葉
            @mission_array[11] = @mission_array[11].to_i + safe_i(@papers[1]) #用紙枚葉
            @mission_array[17] = @mission_array[17].to_i + safe_i(@ctpArr[13]) #刷版
        else
            #何もしない
        end
        @mission_array[48] = @mission_array[48].to_i + safe_i(@papers[1]) #全用紙金額
        @mission_array[3] = @roumu_array[0].to_f + @roumu_array[1].to_f + @roumu_array[2].to_f + @roumu_array[3].to_f + @roumu_array[4].to_f + @roumu_array[7].to_f #製造労務時間
        @mission_array[4] = (@mission_array[3].to_f * @unit_price.d27).to_i
        @mission_array[5] = @roumu_array[5].to_f #制作労務時間
        @mission_array[6] = (@mission_array[5].to_f * @unit_price.d25).to_i
        @mission_array[7] = @roumu_array[6].to_f #デザイン労務時間
        @mission_array[8] = (@mission_array[7].to_f * @unit_price.d26).to_i
        @mission_array[9] = @roumu_array[8].to_f #アセンブリ労務時間
        @mission_array[10] = (@mission_array[9].to_f * @unit_price.d29).to_i
        if job.info.textInfo02&.include?("外注") && ((@mission_array[4]).to_i + (@mission_array[6]).to_i + (@mission_array[8]).to_i + (@mission_array[10]).to_i) == 0
            @mission_array[12] = @mission_array[12].to_i + @sale_sum.to_i #全外注（受注Noの有るもの）の売上高
        end
        @mission_array[14] = @mission_array[14].to_i + @podArr[10] # 1POD
        @mission_array[41] = @mission_array[41].to_i + (@roumu_array[4].to_f * @unit_price.d27).to_i
        @mission_array[42] = @mission_array[42].to_i +  (@ctpArr[12].to_f * @unit_price.d27).to_i # 1CTP労務費
        @mission_array[43] = @mission_array[43].to_i +  (@papers[17].to_f * @unit_price.d27).to_i # 1ロールカッター労務費
        @mission_array[44] = @mission_array[44].to_i +  (@hassoArr[8].to_f * @unit_price.d27).to_i # 1自社配送労務費
        @mission_array[45] = @mission_array[45].to_i +  (@pressArr[8].to_f * @unit_price.d27).to_i # 1印刷労務費
        @mission_array[46] = @mission_array[46].to_i +  (@podArr[9].to_f * @unit_price.d27).to_i # 1POD労務費

          #puts "session[:target_month] #{session[:target_month]}"
        debit = Debit.find_by(job_id: job.id , target_month: session[:target_month])
        #puts "debit #{debit&.name} #{debit&.siwake} #{debit&.den_code}"
        #puts "1@gaicyuArr[1].to_i #{@gaicyuArr[1].to_i}"
        # if debit.blank?
        #     add_datum = AddDatum.find_by(job_id: job.id)
        #     if add_datum&.parent_code.present?
        #         parent_job = Job.find_by(den_id: add_datum.parent_code)
        #         debit = Debit.find_by(job_id: parent_job.id , target_month: session[:target_month])
        #         if debit.blank?
        #             #親コードも密彼らなかったら外注
        #             @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
        #         elsif debit.siwake == "外注"
        #             @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
        #
        #         elsif debit.siwake == "仕入"
        #             @mission_array[16] = @mission_array[16].to_i + safe_i(@gaicyuArr[1])
        #         end
        #     end
        #     parent_job = Job.find_by(den_id: job.den_id)
        #     #何もしない
        # elsif debit.siwake == "外注"
        #     @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
        #
        # elsif debit.siwake == "仕入"
        #     @mission_array[16] = @mission_array[16].to_i + safe_i(@gaicyuArr[1])
        # else
        #     @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
        # end
        @mission_array[15] = @mission_array[15].to_i + safe_i(@gaicyuArr[1])
        @mission_array[35] = @mission_array[35].to_i + safe_i(@hassoArr[9])
        @mission_array[37] = @mission_array[37].to_i + safe_i(@mission_array[18]) #売上
        #間接費（標準原価計算: 単価情報/間接費標準原価割合.xlsx に準拠）
        direct_labor_total = @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i
        if job.info&.textInfo02&.include?("外注") && direct_labor_total == 0
            # info.textInfo02 が外注かつ労務費が 0 の案件には間接費を賦課しない
        else
            # 間接費の対象額 = 売上 - 全用紙費用 - 外注費 - 仕入高 - 運賃
            tmp = (@mission_array[37].to_i - @mission_array[48].to_i - @mission_array[15].to_i - @mission_array[16].to_i - @mission_array[35].to_i).to_f

            if job.info&.textInfo02&.include?("オフ輪")
                web_minus = tmp * 0.2
                @mission_array[47] = @mission_array[47].to_i + web_minus.to_i # オフ輪を減額（20%）
                target_base = tmp - web_minus
            elsif @mission_array[10].to_i > 0 && @tmp_array[1].to_i == 0
                web_minus = tmp * 0.4
                @mission_array[47] = @mission_array[47].to_i + web_minus.to_i # アセンブリのみの案件を減額（40%）
                target_base = tmp - web_minus
            else
                target_base = tmp
            end
            target_base = 0.0 if target_base < 0.0

            # 材料費（インク代）は直課で計算方法を後で検討するため現在は 0 を設定
            @mission_array[19] = 0
            # 雑給 [23]・福利厚生費 [25]・賃借料 [29] は間接費から削除（0 固定）
            @mission_array[23] = 0
            @mission_array[25] = 0
            @mission_array[29] = 0

            # 標準原価割合による各間接費の算出
            @mission_array[21] = safe_i(target_base * STANDARD_INDIRECT_RATES[:roumu])         # 間接労務費（賃金手当 0.099）
            @mission_array[22] = safe_i(target_base * STANDARD_INDIRECT_RATES[:bonus])         # 間接賞与（0.016）
            @mission_array[24] = safe_i(target_base * STANDARD_INDIRECT_RATES[:legal_welfare]) # 間接法定福利（0.023）
            @mission_array[26] = safe_i(target_base * STANDARD_INDIRECT_RATES[:utilities])     # 間接水道光熱費（0.144）
            @mission_array[27] = safe_i(target_base * STANDARD_INDIRECT_RATES[:repair])        # 間接修繕費（0.023）
            @mission_array[28] = safe_i(target_base * STANDARD_INDIRECT_RATES[:taxes])         # 間接租税公課（0.036）
            @mission_array[30] = safe_i(target_base * STANDARD_INDIRECT_RATES[:insurance])     # 間接保険料（0.041）
            @mission_array[31] = safe_i(target_base * STANDARD_INDIRECT_RATES[:supplies])      # 間接消耗品費（0.016）
            @mission_array[49] = safe_i(target_base * STANDARD_INDIRECT_RATES[:vehicle])       # 間接車両費（0.011）
            @mission_array[50] = safe_i(target_base * STANDARD_INDIRECT_RATES[:communication]) # 間接通信費（0.007）
            @mission_array[32] = safe_i(target_base * STANDARD_INDIRECT_RATES[:depreciation])  # 間接減価償却費（0.132）
            @mission_array[33] = safe_i(target_base * STANDARD_INDIRECT_RATES[:misc])          # 間接雑費（0.008）

            # 間接費合計（13項目合計）
            indirect_indices = [19, 21, 22, 24, 26, 27, 28, 30, 31, 49, 50, 32, 33]
            @mission_array[34] = indirect_indices.sum { |idx| safe_i(@mission_array[idx]) }

            # --- 旧・月次会計実績（costsテーブル）按分計算ロジック（参考保存） ---
            # all_tmp = (@cost.all_slip_sales.to_i + @cost.cost23.to_i - @cost.all_paper.to_i - @cost.all_outsourcing.to_i - @cost.all_out_cost.to_i - @cost.all_in_cost.to_i - @cost.all_delivery_cost.to_i - @cost.all_web_minus.to_i).to_f
            # kansetu_wari = target_base / all_tmp
            # kansetu_wari = kansetu_wari.to_f < 0 ? 0 : kansetu_wari.to_f
            # target_roumu = @cost.cost02.to_i - (@cost.all_roumu_product.to_i + @cost.all_roumu_create.to_i + @cost.all_roumu_design.to_i + @cost.cost20.to_i)
            # syu_web = @cost.cost21; syu_sheet = @cost.cost22; syu_other = @cost.cost08 - (syu_web.to_i + syu_sheet.to_i)
        end


        @mission_array[36] = (@tmp_array[0].to_i + @tmp_array[1].to_i + @tmp_array[3].to_i + @tmp_array[8].to_i + @mission_array[15].to_i + @mission_array[16].to_i + @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i + @mission_array[34].to_i)

        #puts "@mission_array[37] #{@mission_array[37]} "
        @mission_array[38] = (@mission_array[37].to_i - @mission_array[36].to_i) #粗利
        @mission_array[39] = @mission_array[37].to_f.zero? ? 0.0 : (@mission_array[38].to_f / @mission_array[37].to_f)
        @mission_array[40] = sales_code_helper(job.sale_id)

        10.times do |i|
            @tmp_hiyou_sum = @tmp_hiyou_sum.to_i + @tmp_array[i].to_i
        end
        @tmp_hiyou_sum = @tmp_hiyou_sum.to_i + @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i

        10.times do |i|
            @mitumori_sum = @mitumori_sum + @mitumori_array[i].to_i
        end
    end
    def mission_twork_plus_helper(twork)
        @cost = Cost.find_by(target_month: session[:target_month])
        @mission_array = Array.new(52, 0)

        @mission_array[7] = twork.work_time.to_f#デザイン労務時間
        @mission_array[8] = twork.work_cost.to_i

        @mission_array[15] = twork.outsourcing_cost.to_i
        @mission_array[16] = twork.purchase_cost.to_i

        @sale_sum = twork.billing_amount.to_i
        @mission_array[18] = twork.billing_amount.to_i
        # 東京案件（Twork）は既存仕様通り間接費を賦課しない（costsテーブル未登録月でもエラーにならないよう旧式は参考コメントとして保持）
        # syu_web = @cost.cost21
        # syu_sheet = @cost.cost22
        # syu_other = @cost.cost08 - (syu_web.to_i + syu_sheet.to_i)
        # if twork.work_time.to_f > 0.0
        #     kansetu_wari = 0.0
        # end
        @mission_array[36] = (@mission_array[15].to_i + @mission_array[16].to_i + @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i + @mission_array[34].to_i)

        @mission_array[37] = safe_i(@mission_array[18]) #売上
        @mission_array[38] = (@mission_array[37].to_i - @mission_array[36].to_i) #粗利
        denominator = @mission_array[37].to_f
        @mission_array[39] = denominator.zero? ? 0.0 : (@mission_array[38].to_f / denominator)
        @mission_array[40] = ""
        @mission_array[41] = ""
        @mission_array[42] = ""
        @mission_array[43] = ""

        @tmp_hiyou_sum = @tmp_hiyou_sum.to_i + @mission_array[15].to_i + @mission_array[16].to_i
        @tmp_hiyou_sum = @tmp_hiyou_sum.to_i + @mission_array[4].to_i + @mission_array[6].to_i + @mission_array[8].to_i + @mission_array[10].to_i

        10.times do |i|
            @mitumori_sum = @mitumori_sum + (@mitumori_array ? @mitumori_array[i].to_i : 0)
        end
    end
end