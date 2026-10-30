class Form::AddPressCollection < Form::Base
  FORM_COUNT = 5
  attr_accessor :add_presses

  def initialize(attributes = {})
    super attributes
    #self.add_presses = FORM_COUNT.times.map { AddPress.new() } unless self.add_presses.present?
    #self.add_presses = [] unless add_presses.present?
    self.add_presses = FORM_COUNT.times.map { AddPress.new() } unless self.add_presses.present?

  end

  # 上でsuper attributesとしているので必要
  def add_presses_attributes=(attributes)
    self.add_presses = attributes.map { |_, v| AddPress.new(v) }
  end

  def save
    # 実際にやりたいことはこれだけ
    # self.memos.map(&:save!)
    # 複数件全て保存できた場合のみ実行したいので、transactionを使用する
    AddPress.transaction do
      #self.add_presses.map(&:save!)
      self.add_presses.map{|v|
        if v.id.blank?
          v.save!
        else
          x = AddPress.find(v.id)
          x.update!( press_num: v.press_num, men: v.men, jisu: v.jisu, machine: v.machine, han: v.han, iro: v.iro, dai: v.dai, kake: v.kake, daitanka: v.daitanka, tanka: v.tanka, dai_price: v.dai_price,
                     zara: v.zara, kin: v.kin, toku: v.toku, upo: v.upo, iroa: v.iroa, irob: v.irob, kake2: v.kake2, page: v.page, sasi: v.sasi)
        end
      }
    end
    return true
  rescue => e
    puts "---press error---"
    puts e
    return false
  end
end