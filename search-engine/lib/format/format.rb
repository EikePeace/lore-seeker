class Format
  attr_reader :included_sets, :excluded_sets

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList[format_name]
    if respond_to?(:build_included_sets)
      @included_sets = build_included_sets
      @excluded_sets = nil
    else
      @included_sets = nil
      @excluded_sets = build_excluded_sets
    end
  end

  def legality(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    if card.extra or !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def build_excluded_sets
    Set[]
  end

  def include_custom_sets?
    false
  end

  def banned?(card)
    legality(card) == "banned"
  end

  def restricted?(card)
    l = legality(card)
    return false if l.nil?
    l.start_with? "restricted"
  end

  def legal?(card)
    legality(card) == "legal"
  end

  def legal_or_restricted?(card)
    legal?(card) or restricted?(card)
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if !include_custom_sets?
        next if card.custom?
      end
      if @included_sets
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
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
    ]
  end

  def deck_size_issues(deck)
    issues = []
    min_mainboard_size = 60 - 5 * deck.sideboard.select{|iter_card| iter_card.last.name == "Advantageous Proclamation"}.sum(&:first) # assumes all Proclamations in the sideboard are used
    if deck.number_of_mainboard_cards < min_mainboard_size
      issues << [:main_size_min, deck.number_of_mainboard_cards, min_mainboard_size]
    end
    if deck.number_of_sideboard_cards > 15
      issues << [:side_size_max, deck.number_of_sideboard_cards, 15]
    end
    issues
  end

  def deck_card_issues(deck)
    issues = []
    deck.card_counts.each do |card, count|
      card_legality = legality(card)
      case card_legality
      when "legal"
        if count > 4 and not card.allowed_in_any_number?
          issues << [:copies, card, count, 4]
        end
      when "restricted"
        if count > 1
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

  def format_pretty_name
    raise "Subclass responsibility"
  end

  def format_name
    format_pretty_name.downcase
  end

  def to_s
    if @time
      "<Format:#{format_name}:#{@time}>"
    else
      "<Format:#{format_name}>"
    end
  end

  def inspect
    to_s
  end

  def ban_events
    @ban_list.events
  end

  class << self
    def formats_index
      # Removed spaces so you can say "lw block" lw-block lwblock lw_block or whatever
      {
        "freeform"                   => FormatFreeform,
        "iablock"                    => FormatIceAgeBlock,
        "iceageblock"                => FormatIceAgeBlock,
        "mrblock"                    => FormatMirageBlock,
        "mirageblock"                => FormatMirageBlock,
        "tpblock"                    => FormatTempestBlock,
        "tempestblock"               => FormatTempestBlock,
        "usblock"                    => FormatUrzaBlock,
        "urzablock"                  => FormatUrzaBlock,
        "mmblock"                    => FormatMasquesBlock,
        "masquesblock"               => FormatMasquesBlock,
        "marcadianmasquesblock"      => FormatMasquesBlock,
        "inblock"                    => FormatInvasionBlock,
        "invasionblock"              => FormatInvasionBlock,
        "odblock"                    => FormatOdysseyBlock,
        "odysseyblock"               => FormatOdysseyBlock,
        "onblock"                    => FormatOnslaughtBlock,
        "onslaughtblock"             => FormatOnslaughtBlock,
        "miblock"                    => FormatMirrodinBlock,
        "mirrodinblock"              => FormatMirrodinBlock,
        "tsblock"                    => FormatTimeSpiralBlock,
        "timespiralblock"            => FormatTimeSpiralBlock,
        "ravblock"                   => FormatRavinicaBlock,
        "ravnicablock"               => FormatRavinicaBlock,
        "kamigawablock"              => FormatKamigawaBlock,
        "chkblock"                   => FormatKamigawaBlock,
        "championsofkamigawablock"   => FormatKamigawaBlock,
        "lwblock"                    => FormatLorwynBlock,
        "lorwynblock"                => FormatLorwynBlock,
        "lorwynshadowmoorblock"      => FormatLorwynBlock,
        "alablock"                   => FormatShardsOfAlaraBlock,
        "alarablock"                 => FormatShardsOfAlaraBlock,
        "shardsofalarablock"         => FormatShardsOfAlaraBlock,
        "zendikarblock"              => FormatZendikarBlock,
        "zenblock"                   => FormatZendikarBlock,
        "scarsofmirrodinblock"       => FormatScarsOfMirrodinBlock,
        "somblock"                   => FormatScarsOfMirrodinBlock,
        "innistradblock"             => FormatInnistradBlock,
        "isdblock"                   => FormatInnistradBlock,
        "returntoravnicablock"       => FormatReturnToRavnicaBlock,
        "rtrblock"                   => FormatReturnToRavnicaBlock,
        "therosblock"                => FormatTherosBlock,
        "thsblock"                   => FormatTherosBlock,
        "tarkirblock"                => FormatTarkirBlock,
        "ktkblock"                   => FormatTarkirBlock,
        "khansoftarkirblock"         => FormatTarkirBlock,
        "battleforzendikarblock"     => FormatBattleForZendikarBlock,
        "bfzblock"                   => FormatBattleForZendikarBlock,
        "soiblock"                   => FormatShadowsOverInnistradBlock,
        "shadowsoverinnistradblock"  => FormatShadowsOverInnistradBlock,
        "kldblock"                   => FormatKaladeshBlock,
        "kaladeshblock"              => FormatKaladeshBlock,
        "akhblock"                   => FormatAmonkhetBlock,
        "amonkhetblock"              => FormatAmonkhetBlock,
        "ixalanblock"                => FormatIxalanBlock,
        "xlnblock"                   => FormatIxalanBlock,
        "unsets"                     => FormatUnsets,
        "un-sets"                    => FormatUnsets,
        "standard"                   => FormatStandard,
        "brawl"                      => FormatBrawl,
        "modern"                     => FormatModern,
        "frontier"                   => FormatFrontier,
        "pioneer"                    => FormatPioneer,
        "legacy"                     => FormatLegacy,
        "vintage"                    => FormatVintage,
        "pauper"                     => FormatPauper,
        "pennydreadful"              => FormatPennyDreadful,
        "pd"                         => FormatPennyDreadful,
        "penny"                      => FormatPennyDreadful,
        "commander"                  => FormatCommander,
        "edh"                        => FormatCommander,
        "duelcommander"              => FormatDuelCommander,
        "dueledh"                    => FormatDuelCommander,
        "duel"                       => FormatDuelCommander,
        "mtgocommander"              => FormatMTGOCommander,
        "mtgoedh"                    => FormatMTGOCommander,
        "historic"                   => FormatHistoric,
        "canadianhighlander"         => FormatCanadianHighlander,
        "canlander"                  => FormatCanadianHighlander,
        "customstandard"             => FormatCustomStandard,
        "custard"                    => FormatCustomStandard,
        "cstd"                       => FormatCustomStandard,
        "cs"                         => FormatCustomStandard,
        "custometernal"              => FormatCustomEternal,
        "ce"                         => FormatCustomEternal,
        "custommodern"               => FormatCustomModern,
        "cmod"                       => FormatCustomModern,
        "cm"                         => FormatCustomModern,
        "fusiondragonhighlander"     => FormatFDH,
        "fdh"                        => FormatFDH,
        "fusioncommander"            => FormatFDH,
        "fusionedh"                  => FormatFDH,
        "eldercustomhighlander"      => FormatECH,
        "eldercockatricehighlander"  => FormatECH,
        "ech"                        => FormatECH,
        "customcommander"            => FormatECH,
        "customedh"                  => FormatECH,
        "cc"                         => FormatECH,
        "cedh"                       => FormatECH,
        "elderxmagehighlander"       => FormatEXH,
        "exh"                        => FormatEXH,
        "custompauper"               => FormatCustomPauper,
        "cp"                         => FormatCustomPauper,
        "custombrawl"                => FormatCustomBrawl,
        "crawl"                      => FormatCustomBrawl,
        "cb"                         => FormatCustomBrawl,
        "chocoeternal"               => FormatChocoEternal,
        "chocet"                     => FormatChocoEternal,
        "choco"                      => FormatChocoEternal,
      }
    end

    def all_format_classes
      @all_format_classes ||= formats_index.values.uniq
    end

    def [](format_name)
      format_name = format_name.downcase.gsub(/\s|-|_/, "")
      return FormatAny if format_name == "*"
      formats_index[format_name] || FormatUnknown
    end
  end
end

require_relative "format_vintage"
require_relative "format_commander"
require_relative "format_standard"
require_relative "format_commander"
require_relative "format_custom_standard"
require_relative "format_custom_eternal"
require_relative "format_ech"
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end
