class FormatCustomBrawl < FormatCustomStandard
  def format_pretty_name
    "Custom Brawl"
  end

  def deck_issues(deck)
    issues = []
    deck.physical_cards.select {|card| card.is_a?(UnknownCard) }.each do |card|
      issues << [:unknown_card, card]
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
      issues << [:size, deck.number_of_total_cards, 60]
    end
    unless deck.number_of_sideboard_cards.between?(1, 2)
      issues << [:commander_sideboard_size, deck.number_of_sideboard_cards, false]
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
          issues << [:copies, card, count, 1]
        end
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
    issues
  end

  def deck_commander_issues(deck)
    cards = deck.sideboard.flat_map{|n,c| [c] * n}
    return [] unless cards.size.between?(1, 2)

    issues = []
    cards.each do |c|
      if not c.brawler?
        issues << [:commander, c]
      elsif legality(c) == "restricted"
        issues << [:banned_commander, c]
      end
    end

    # Brawl never had any partners, it's copy&pasted commander logic
    if cards.size == 2
      a, b = cards
      issues << [:partner, a] unless a.partner?
      issues << [:partner, b] unless b.partner?
      if a.partner and a.partner.name != b.name
        issues << [:partner_with, a, b]
      end
      if b.partner and b.partner.name != a.name
        issues << [:partner_with, b, a]
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
        issues << [:color_identity, card, card_color_identity, color_identity]
      end
    end
    if basics.size > 1
      issues << [:brawl_basics]
    end
    issues
  end
end
