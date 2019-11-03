class FormatCustomBrawl < FormatCustomStandard
  def format_pretty_name
    "Custom Brawl"
  end

  def deck_issues(deck)
    issues = []
    deck.physical_cards.select {|card| card.is_a?(UnknownCard) }.each do |card|
      issues << "Unknown card name: #{card.name}"
    end
    return issues unless issues.empty?
    [
      *deck_size_issues(deck),
      *deck_card_issues(deck),
      *deck_commander_issues(deck),
      *deck_color_identity_issues(deck),
    ]
  end

  def deck_size_issues(deck)
    issues = []
    if deck.number_of_total_cards != 60
      issues << "Deck must contain exactly 60 cards, has #{deck.number_of_total_cards}"
    end
    unless deck.number_of_sideboard_cards.between?(1, 2)
      issues << "Deck's sideboard must be exactly 1 card or 2 partner cards designated as commander, has #{deck.number_of_sideboard_cards}"
    end
    issues
  end

  def deck_card_issues(deck)
    issues = []
    deck.card_counts.each do |card, name, count|
      card_legality = legality(card)
      case card_legality
      when "legal", "restricted"
        if count > 1 and not card.allowed_in_any_number?
          issues << "Deck contains #{count} copies of #{name}, only up to 1 allowed"
        end
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
    issues
  end

  def deck_commander_issues(deck)
    cards = deck.sideboard.flat_map{|n,c| [c] * n}
    return [] unless cards.size.between?(1, 2)

    issues = []
    cards.each do |c|
      if not c.brawler?
        issues << "#{c.name} is not a valid commander"
      elsif legality(c) == "restricted"
        issues << "#{c.name} is banned as commander"
      end
    end

    # Brawl never had any partners, it's copy&pasted commander logic
    if cards.size == 2
      a, b = cards
      issues << "#{a.name} is not a valid partner card" unless a.partner?
      issues << "#{b.name} is not a valid partner card" unless b.partner?
      if a.partner and a.partner.name != b.name
        issues << "#{a.name} can only partner with #{a.partner.name}"
      end
      if b.partner and b.partner.name != a.name
        issues << "#{b.name} can only partner with #{b.partner.name}"
      end
    end

    issues
  end

  def deck_color_identity_issues(deck)
    color_identity = deck.color_identity
    return [] unless color_identity
    color_identity = color_identity.chars.to_set
    issues = []
    basics = Set[]
    deck.card_counts.each do |card, name, count|
      card_color_identity = card.color_identity.chars.to_set
      next if card_color_identity <= color_identity
      if color_identity.empty? and card.types.include?("basic")
        basics << card_color_identity
      else
        issues << "Deck has a color identity of #{color_identity_name(color_identity)}, but #{name} has a color identity of #{color_identity_name(card_color_identity)}"
      end
    end
    if basics.size > 1
      issues << "Deck with colorless commander can contain basic lands of only one color"
    end
    issues
  end
end
