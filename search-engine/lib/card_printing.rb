class XmageCache
  def initialize
    @cache = {}
    @today_cache = nil
    @today_cache_time = nil
  end

  def get(date)
    return nil if date > Date.today # don't cache future printing lists
    if date == Date.today # expire today's cache after an hour
      if @today_cache_time.nil? or @today_cache_time.to_date < Date.today or @today_cache_time < Time.now - (60 * 60)
        path = Pathname(__dir__) + "../../index/xmage-printings/#{date}.json"
        @today_cache = path.exist? ? JSON.parse(path.read) : nil
        @today_cache_time = Time.now
      end
      return @today_cache
    end
    @cache[date] ||= begin
      path = Pathname(__dir__) + "../../index/xmage-printings/#{date}.json"
      path.exist? ? JSON.parse(path.read) : nil
    end
  end
end

class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_reader :watermark, :rarity, :artist_name, :multiverseid, :number, :frame, :flavor, :flavor_normalized, :border
  attr_reader :rarity_code, :print_sheet, :partner, :oversized, :frame_effects, :foiling, :spotlight
  attr_reader :textless, :fullart, :buyabox
  attr_reader :printed_name, :printed_text, :printed_typeline

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code
  attr_reader :release_date_i

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index, :partner

  def initialize(card, set, data)
    @card = card
    @set = set
    @others = nil
    @release_date = data["release_date"] ? Date.parse(data["release_date"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["watermark"]
    @number = data["number"]
    @multiverseid = data["multiverseid"]
    if data["artist"]
      @artist_name = data["artist"].normalize_accents # TODO: move to indexer
    else
      warn "Card #{card.name} in #{set.code} lacks artist"
      @artist_name = "Unknown"
    end
    @flavor = data["flavor"] || -""
    @flavor_normalized = @flavor.normalize_accents
    @foiling = data["foiling"]
    @border = data["border"] || @set.border
    @frame = data["frame"]
    @frame_effects = data["frame_effects"] || []
    @printed_name = data["originalName"] || @card.name
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
    @partner = data["partner"]
    @oversized = data["oversized"]
    @spotlight = data["spotlight"]
    @fullart = data["fullart"]
    @textless = data["textless"]
    @buyabox = data["buyabox"]

    @paper = data["paper"]
    @arena = data["arena"]
    @mtgo = data["mtgo"]

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code
  end

  def arena?
    !!@arena
  end

  def paper?
    !!@paper
  end

  def mtgo?
    !!@mtgo
  end

  def xmage?(time=nil)
    time ||= Time.now
    date = time.to_date
    until date < Date.new(2010, 3, 20) do
      card_printings = $XmageCache.get(date)
      return card_printings.has_key?(name) && card_printings[name].include?(set.code) unless card_printings.nil?
      date -= 1
      next
    end
    false
  end

  def in_boosters?
    (@set.has_boosters? or @set.in_other_boosters?) and !@exclude_from_boosters
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
    foreign_names foreign_names_normalized mana_hash funny color_indicator color_indicator_set
    related first_regular_release_date reminder_text augment
    display_power display_toughness display_mana_cost
    primary? secondary? front? back? partner? allowed_in_any_number?
    commander? brawler? custom?
    num_exh_votes
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

  def valid_partner_for?(other)
    return unless partner? and other.partner?
    if partner
      return false unless partner.name == other.name
    end
    if other.partner
      return false unless name == other.partner.name
    end
    true
  end

  def main_front
    PhysicalCard.for(self).main_front
  end
end
