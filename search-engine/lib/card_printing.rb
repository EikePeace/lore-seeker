class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_reader :watermark, :rarity, :artist_name, :multiverseid, :number, :frame, :flavor, :flavor_normalized, :border, :timeshifted, :printed_text, :printed_typeline
  attr_reader :rarity_code, :print_sheet

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code
  attr_reader :release_date_i

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index

  def initialize(card, set, data)
    @card = card
    @set = set
    @others = nil
    @release_date = data["release_date"] ? Date.parse(data["release_date"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["watermark"]
    @number = data["number"]
    @multiverseid = data["multiverseid"]
    @artist_name = data["artist"]
    @flavor = data["flavor"] || -""
    @flavor_normalized = @flavor.tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-")
    @flavor_normalized = @flavor if @flavor_normalized == @flavor # Memory saving trick
    @border = data["border"] || @set.border
    @frame = data["frame"] || @set.frame
    @timeshifted = data["timeshifted"] || false
    @printed_text = (data["originalText"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-")
    unless card.funny
      @printed_text = @printed_text.gsub(/\s*\([^\(\)]*\)/, "")
    end
    @printed_text = -@printed_text.sub(/\s*\z/, "").gsub(/ *\n/, "\n").sub(/\A\s*/, "")
    @printed_typeline = (data["originalType"] || "").tr("\u2014", "-")
    rarity = data["rarity"]
    @rarity_code = %W[basic common uncommon rare mythic special].index(rarity) or raise "Unknown rarity #{rarity}"
    @exclude_from_boosters = data["exclude_from_boosters"]
    @print_sheet = data["print_sheet"]

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code
  end

  # "foilonly", "nonfoil", "both"
  def foiling
    case @set.foiling
    when "nonfoil", "foilonly", "both"
      @set.foiling
    when "booster_both"
      return "both" if in_boosters?
      "unknown_for_nonbooster"
    when "precon"
      # FIXME: This is extremely unperformant
      if @set.decks.empty?
        warn "#{@set.code} is not a precon"
        return "not a precon"
      end
      actual = @set.decks
        .flat_map(&:cards_with_sideboard)
        .map(&:last)
        .select{|c| c.parts.map(&:name).include?(name) }
        .map(&:foil)
        .uniq
      if actual == []
        binding.pry
        "missing_from_precon"
      elsif actual == [false]
        "nonfoil"
      elsif actual == [true]
        "foilonly"
      else
        "precon with both, wat?"
      end
    else
      "#{@set.foiling} -> totally_unknown"
    end
  end

  def in_boosters?
    @set.has_boosters? and !@exclude_from_boosters
  end

  def exclude_from_boosters?
    !!@exclude_from_boosters
  end

  def rarity
    %W[basic common uncommon rare mythic special].fetch(@rarity_code)
  end

  def ui_rarity
    if @print_sheet
      "#{rarity} (#{@print_sheet})"
    else
      rarity
    end
  end

  def year
    @release_date.year
  end

  def set_type
    @set.type
  end

  # This is a bit too performance-critical to use method_missing
  # It's not a huge difference, but no reason to waste ~5% of execution time on it
  def set_name
    @set.name
  end

  %W[block_code block_name online_only?].each do |m|
    eval("def #{m}; @set.#{m}; end")
  end
  %W[name names layout colors mana_cost reserved types cmc text text_normalized power
    toughness loyalty stability extra color_identity has_multiple_parts? typeline
    first_release_date last_release_date printings life hand rulings
    foreign_names foreign_names_normalized mana_hash funny color_indicator
    related first_regular_release_date reminder_text augment
    display_power display_toughness
    primary? secondary? front? back?
  ].each do |m|
    eval("def #{m}; @card.#{m}; end")
  end

  def legality_information(time=nil)
    @card.legality_information(time)
  end

  def gatherer_link
    return nil unless multiverseid
    "http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=#{multiverseid}"
  end

  def magiccards_info_link
    "http://magiccards.info/#{set_code}/en/#{number}.html"
  end

  include Comparable
  def <=>(other)
    [name, set, number.to_i, number] <=> [other.name, other.set, other.number.to_i, other.number]
  end

  def age
    [0, (release_date - first_regular_release_date).to_i].max
  end

  def inspect
    "CardPrinting(#{name}, #{set_code})"
  end

  def id
    "#{set_code}/#{number}"
  end

  def to_s
    inspect
  end
end
