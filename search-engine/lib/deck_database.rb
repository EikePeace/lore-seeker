class DeckDatabase
  def initialize(db)
    @db = db
  end

  def resolve_card(count, set_code, card_number, foil=false)
    set = @db.sets[set_code] or raise "Set not found #{set_code}"
    printing = set.printings.find{|cp| cp.number == card_number}
    raise "Card not found #{set_code}/#{card_number}" unless printing
    [count, PhysicalCard.for(printing, !!foil)]
  end

  def resolve_custom(count, set_code, set_version, card_number, card_name, foil=false)
    set = @db.sets[set_code] or raise "Set not found #{set_code}"
    return [count, OutdatedCard.new(card_name, set, set_version)] if set.custom? && set.custom_version != set_version
    printing = set.printings.find{|cp| cp.number == card_number}
    return [count, UnknownCard.new(card_name)] unless printing && printing.name == card_name
    [count, PhysicalCard.for(printing, !!foil)]
  end

  def load!(path=Pathname("#{__dir__}/../../index/deck_index.json"))
    JSON.parse(path.read).each do |deck|
      set_code = deck["set_code"]
      set = @db.sets[set_code] or raise "Set not found #{set_code}"
      set.decks << load_deck(deck)
    end
  end

  def load_deck(deck, custom=false)
    set_code = deck["set_code"]
    set = @db.sets[set_code]
    cards = deck["cards"].map{|c| custom ? resolve_custom(*c) : resolve_card(*c) }
    sideboard = deck["sideboard"].map{|c| custom ? resolve_custom(*c) : resolve_card(*c) }
    commanders = deck["commanders"].to_a.map{|c| custom ? resolve_custom(*c) : resolve_card(*c) }
    brawlers = deck["brawlers"].to_a.map{|c| custom ? resolve_custom(*c) : resolve_card(*c) }
    date = deck["release_date"]
    date = date ? Date.parse(date) : nil
    deck = PreconDeck.new(
      set,
      deck["name"],
      deck["type"],
      date,
      cards,
      sideboard,
      commanders,
      brawlers,
    )
    return deck
  end

  def load_custom(path)
    JSON.parse(path.read).map{ |deck| load_deck(deck, true) }
  end
end
