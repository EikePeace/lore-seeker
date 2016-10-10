class FormatShardsOfAlaraBlock < Format
  def format_pretty_name
    "Shards of Alara Block"
  end

  def build_format_sets
    Set["ala", "cfx", "arb"]
  end
end
