class FormatMirrodinBlock < Format
  def format_pretty_name
    "Mirrodin Block"
  end

  def build_included_sets
    Set["mi", "ds", "5dn"]
  end
end
