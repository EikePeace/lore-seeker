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
      issues << "Deck must contain at least 100 mainboard cards, has only #{deck.number_of_mainboard_cards}"
    end
    if deck.number_of_sideboard_cards > 0
      issues << "Sideboards are not allowed in Canadian Highlander"
    end
    issues
  end

  def deck_card_issues(deck)
    issues = []
    points = []
    deck.card_counts.each do |card, name, count|
      card_legality = legality(card)
      case card_legality
      when "legal"
        if count > 1 and not card.allowed_in_any_number?
          issues << "Deck contains #{count} copies of #{name}, only up to 1 allowed"
        end
      when /^restricted-/
        points << [name, PointsList[name]]
      when "banned"
        issues << "#{name} is banned"
      when nil
        issues << "#{name} is not in the format"
      when /^banned-/
        issues << "#{name} is not yet implemented in XMage"
      else
        issues << "Unknown legality #{card_legality} for #{name}"
      end
    end
    if points.sum(&:last) > 10
      points_desc = points.map{|name, card_points| "#{name}: #{card_points} point#{card_points == 1 ? "" : "s"}" }.inject{|a, b| "#{a}, #{b}" }
      issues << "A maximum of 10 points are allowed but this deck has #{points.sum(&:last)} points (#{points_desc})"
    end
    issues
  end

  def self.load_points_list
    points_file = (Pathname(__dir__) + "../../../index/canlander-points-list.json")
    JSON.parse(points_file.read)
  end

  PointsList = load_points_list
end
