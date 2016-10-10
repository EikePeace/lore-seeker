class FormatTimeSpiralBlock < Format
  def format_pretty_name
    "Time Spiral Block"
  end

  def build_format_sets
    Set["ts", "tsts", "pc", "fut"]
  end
end
