class PaperLedger < PressBoardModel
  self.table_name = "paper_ledgers"

  LEDGER_TYPES = {
    "flat"       => "平判台帳",
    "special"    => "平判特殊紙台帳",
    "roll"       => "巻取り台帳",
    "king_heart" => "キング・ハート台帳"
  }.freeze

  def ledger_type_label
    LEDGER_TYPES[ledger_type.to_s] || ledger_type.to_s
  end
end
