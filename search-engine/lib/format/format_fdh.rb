class FormatFDH < Format
  def initialize(time=nil)
    super(time)
    @included_sets = build_included_sets
    @excluded_sets = build_excluded_sets
    @official_ban_list = BanList["commander"]
    @custom_ban_list = BanList["custom eternal"]
  end

  def format_pretty_name
    "Fusion Dragon Highlander"
  end

  def include_custom_sets?
    true
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
    if deck.number_of_total_cards != 100
      issues << "Deck must contain exactly 100 cards, has #{deck.number_of_total_cards}"
    end
    unless deck.number_of_sideboard_cards.between?(1, 2)
      issues << "Deck's sideboard must be exactly 1 card or 2 partner cards designated as commander, has #{deck.number_of_sideboard_cards}"
    end
    custom_nonland_cards = deck.mainboard.count{|c| c.custom? && !card.types.include?("land") }
    if custom_nonland_cards < 15
      issues << "Main deck must contain at least 15 custom nonland cards, has #{custom_nonland_cards}"
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
      if not c.custom?
        issues << "Commanders must be custom cards, but #{c.name} is an official card"
      end
      if not c.commander?
        issues << "#{c.name} is not a valid commander"
      elsif legality(c) == "restricted"
        issues << "#{c.name} is banned as commander"
      end
    end

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
    deck.card_counts.each do |card, name, count|
      card_color_identity = card.color_identity.chars.to_set
      unless card_color_identity <= color_identity
        issues << "Deck has a color identity of #{color_identity_name(color_identity)}, but #{name} has a color identity of #{color_identity_name(card_color_identity)}"
      end
    end
    issues
  end

  def build_included_sets
    Format["custom eternal"].new(@time).build_included_sets
  end

  def build_excluded_sets
    Format["commander"].new(@time).build_excluded_sets
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if card.custom?
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
  end

  def legality(card)
    status = super(card)
    return status if status != "legal"
    card = card.main_front if card.is_a?(PhysicalCard)
    if card.custom?
      @custom_ban_list.legality(card.name, @time)
    else
      @official_ban_list.legality(card.name, @time)
    end
  end
end
