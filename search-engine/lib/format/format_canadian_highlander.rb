class FormatCanadianHighlander < FormatVintage
  def legality(card)
    status = super(card)
    return status if status != "legal"
    if PointsList.has_key?(card.name)
      "restricted-#{PointsList[card.name]}"
    else
      status
    end
  end

  def format_pretty_name
    "Canadian Highlander"
  end

  def deck_legality(deck)
    num_names = deck.physical_cards.count{|card| card.is_a?(UnknownCard) }
    return "This deck contains an entry that's just a name, not a card." if num_names == 1
    return "This deck contains #{num_names} entries that are just names, not cards." unless num_names == 0
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card).nil? }
    return "#{offending_card.name} is not legal in Canadian Highlander." unless offending_card.nil?
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card) == "banned" }
    return "#{offending_card.name} is banned in Canadian Highlander." unless offending_card.nil?
    return "Minimum mainboard size is 100 cards, but this deck only has #{deck.number_of_mainboard_cards}." if deck.number_of_mainboard_cards < 100
    return "Sideboards are not allowed in Canadian Highlander." if deck.number_of_sideboard_cards > 0
    offending_card = deck.physical_cards.map(&:main_front).find{|card| !card.allowed_in_any_number? && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.sum(&:first) > 1 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.sum(&:first)
      return "Only one copy of the same nonbasic card is allowed, but this deck has #{count} copies of #{offending_card.name}."
    end
    points = deck.physical_cards.map(&:main_front).map(&:name).sum{|card| PointsList.has_key?(card) ? PointsList[card] : 0 }
    return "A maximum of 10 points are allowed but this deck has #{points} points." if points > 10
  end

  def self.load_points_list
    points_file = (Pathname(__dir__) + "../../../index/canlander-points-list.json")
    JSON.parse(points_file.read)
  end

  PointsList = load_points_list
end
