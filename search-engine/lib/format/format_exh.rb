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

  # for optimization purposes

  def banned?(card)
    FormatECH.instance_method(:legality).bind(self).call(card) == "banned"
  end

  def restricted?(card)
    status = FormatECH.instance_method(:legality).bind(self).call(card)
    status == "restricted" && card.xmage?(@time)
  end

  def legal?(card)
    status = FormatECH.instance_method(:legality).bind(self).call(card)
    status == "legal" && card.xmage?(@time)
  end

  def legal_or_restricted?(card)
    status = FormatECH.instance_method(:legality).bind(self).call(card)
    (status == "legal" || status == "restricted") && card.xmage?(@time)
  end
end
