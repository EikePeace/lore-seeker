class FormatEXH < FormatECH
  def initialize(time=nil)
    super(time)
    @ban_list = BanList["elder custom highlander"]
  end

  def format_pretty_name
    "Elder XMage Highlander"
  end

  def legality(card)
    status = super(card)
    if status == "legal" or status == "restricted"
      unless card.xmage?(@time)
        status = "banned-#{card.num_exh_votes}"
      end
    end
    status
  end
end
