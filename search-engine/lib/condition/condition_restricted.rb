class ConditionRestricted < ConditionFormat
  def to_s
    timify_to_s "restricted:#{maybe_quote(@format_name)}"
  end

  private

  def legality_ok?(legality)
    return false if legality.nil?
    legality.start_with? "restricted"
  end
end
