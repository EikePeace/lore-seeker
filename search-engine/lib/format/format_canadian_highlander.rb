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

  def deck_size_issues(deck)
    issues = []
    if deck.number_of_mainboard_cards < 100
      issues << [:main_size_min, deck.number_of_mainboard_cards, 100]
    end
    if deck.number_of_sideboard_cards > 0
      issues << [:side_size_max, deck.number_of_sideboard_cards, 0]
    end
    issues
  end

  def deck_card_issues(deck)
    issues = []
    points = []
    deck.card_counts.each do |card, count|
      card_legality = legality(card)
      case card_legality
      when "legal"
        if count > 1 and not card.allowed_in_any_number?
          issues << [:copies, card, count, 1]
        end
      when /^restricted-/
        points << [card, count, PointsList[card.name]]
      when "banned"
        issues << [:banned, card]
      when nil
        issues << [:not_in_format, card]
      when /^banned-/
        issues << [:not_on_xmage, card]
      else
        issues << [:unknown_legality, card, card_legality]
      end
    end
    if points.sum{|card, count, card_points| count * card_points} > 10
      issues << [:canlander_points, 10, points]
    end
    issues
  end

  def self.load_points_list
    points_file = (Pathname(__dir__) + "../../../index/canlander-points-list.json")
    JSON.parse(points_file.read)
  end

  PointsList = load_points_list
end
