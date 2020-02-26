class ConditionInXmage < ConditionIn
  def match?(card)
    card.xmage?(@time)
  end

  def metadata!(key, value)
    super
    @time = value if key == :time
  end

  def to_s
    timify_to_s "in:xmage"
  end
end
