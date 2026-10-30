class Form::AddValueCollection < Form::Base
  FORM_COUNT = 5
  attr_accessor :add_values

  def initialize(attributes = {})
    super attributes

    self.add_values = FORM_COUNT.times.map { AddValue.new() } unless self.add_values.present?

   end

    # 上でsuper attributesとしているので必要
    def add_values_attributes=(attributes)
      self.add_values = attributes.map { |_, v| AddValue.new(v) }

    end

    def save
      # 実際にやりたいことはこれだけ
      # self.memos.map(&:save!)
      # 複数件全て保存できた場合のみ実行したいので、transactionを使用する
      AddValue.transaction do
        #self.add_values.map(&:save!)
        self.add_values.map{|v|
          if v.id.blank?
            v.save!
          else
            puts "----update----"
            x = AddValue.find(v.id)
            x.update!(  paper_name: v.paper_name  ,me: v.me  ,han: v.han  ,ren: v.ren  ,ktanka: v.ktanka  ,mtanka: v.mtanka  ,jisu: v.jisu  ,yobi: v.yobi   ,press_num: v.press_num  ,special: v.special  ,upo: v.upo  ,gold: v.gold  ,kaleid: v.kaleid  ,other: v.other  ,sasi: v.sasi  ,iroko: v.iroko  ,sale_price: v.sale_price  ,paper_price: v.paper_price, ita: v.ita, tori: v.tori, dai: v.dai, men: v.men )
          end
        }
      end
      return true
    # rescue => e
    #   puts "---value error---"
    #   puts e
    #   puts e
    #   return false
    end
  end