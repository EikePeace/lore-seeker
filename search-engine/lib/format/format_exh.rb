class FormatEXH < FormatECH
  def initialize(time=nil)
    super(time)
    @ban_list = BanList["elder cockatrice highlander"]
  end

  def format_pretty_name
    "Elder XMage Highlander"
  end

  def legality(card)
    status = super(card)
    if status == "legal" or status == "restricted"
      unless card_list(@time).include?(card.name)
        status = "banned-#{card.num_exh_votes}"
      end
    end
    status
  end

  def card_list(date)
    date ||= Date.today
    until date <= Date.new(2019, 9, 23) do
      card_file = (Pathname(__dir__) + "../../../index/exh-cards/#{date}.json")
      return JSON.parse(card_file.read) if card_file.exist?
      date -= 1
      next
    end
    []
  end
end
