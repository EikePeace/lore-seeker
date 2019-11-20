class ConditionIsXmage < ConditionSimple
  def match?(card)
    card.xmage?(@time)
  end

  def to_s
    "game:xmage"
  end
end
