class FormatChocoEternal < Format
  def format_pretty_name
    "ChocoEternal"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    Set[
      "mh1", "ayr", "soi", "ths", "bng", "jou", "hlw", "shm", "eve", "bfz", "grn", "rna",
    ]
  end
end