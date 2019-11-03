class FormatFreeform < Format
  def format_pretty_name
    "Freeform"
  end

  def legality(card)
    "legal"
  end

  def include_custom_sets?
    true
  end

  def deck_issues(deck)
    []
  end

  def in_format?(card)
    true
  end

  def deck_issues(deck)
    []
  end
end
