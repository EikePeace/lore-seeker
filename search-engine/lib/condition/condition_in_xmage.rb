class ConditionInXmage < ConditionSimple
  def match?(card)
    card.card.xmage?(@time)
  end

  def to_s
    "in:xmage"
  end
end
