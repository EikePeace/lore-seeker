class FormatEXH < FormatECH
  def initialize(time=nil)
    super(time)
    @ban_list = BanList["elder cockatrice highlander"]
  end

  def format_pretty_name
    "Elder XMage Highlander"
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      return true if card_list(@time).include?(printing.name)
    end
    false
  end

  def card_list(date)
    until date <= Date.new(2019, 9, 23) do
      card_file = (Pathname(__dir__) + "../../../index/exh-cards/#{date}.json")
      return JSON.parse(card_file.read) if card_file.exist?
      date -= 1
      next
    end
    []
  end
end
