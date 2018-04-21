class OracleVerifier
  def initialize
    @versions = {}
    @canonical = {}
  end

  def add(set_code, card_data)
    name = card_data["name"]
    @versions[name] ||= []
    @versions[name] << [set_code, card_data]
  end

  def report_variants!(card_name, key, variants)
    puts "Key #{key} of card #{card_name} is inconsistent between versions"
    variants.each do |variant, printings|
      puts "* #{variant.inspect} - #{printings.join(" ")}"
    end
    puts ""
  end

  def validate_and_report!(card_name, versions)
    # All versions are same, no reason to dig deeper
    if versions.map(&:last).uniq.size == 1
      @canonical[card_name] = versions[0][1]
    end
    # Something failed
    keys = versions.map(&:last).map(&:keys).inject(&:|)
    @canonical[card_name] = {}
    keys.each do |key|
      variants = {}
      versions.each do |set_code, version|
        variant = version[key]
        variants[variant] ||= []
        variants[variant] << set_code
      end
      canonical_variant = nil
      canonical_variant_source = nil

      if variants.size == 1
        # This key is fine
        canonical_variant = variants.keys[0]
      else
        # This key is broken
        # We need to fix it
        if key == "rulings"
          # That's low value fail, would be nice if they fixed it, but whatever
          canonical_variant = variants.keys.max_by{|v| v.to_s.size}
        elsif key == "supertypes"
          # Planeswalkers, promos didn't get updated yet
          if variants.keys.to_set == [nil, ["Legendary"]].to_set
            canonical_variant = ["Legendary"]
          end
        elsif key == "subtypes"
          if card_name == "Aesthir Glider"
            canonical_variant_source = "dom"
          end
        else
          # Transition
          rx = /his or her|him or her|he or she|mana pool|target creature or player/i
          if variants.keys.any?{|x| x =~ rx }
            good = variants.keys.select{|x| x !~ rx}
            if good.size == 1
              canonical_variant = good[0]
            end
          elsif variants.keys.any?{|x| x =~ /this spell/i } and variants.keys.any?{|x| x !~ /this spell/i }
            good = variants.keys.select{|x| x =~ /this spell/i }
            if good.size == 1
              canonical_variant = good[0]
            end
          else
            # first line: never updated (also: UGL,UNH,UST,S00)
            # second line: not updated yet
            known_outdated = %W[
              ced cedi bok st2k v17 cp2
              rep mbp rqs arena itp at mprp wotc thgt dpa jr cp gtw ptc sus jr fnmp pro mgdc mlp
            ]
            maybe_good_variants = {}
            variants.each do |variant, sets|
              sets -= known_outdated
              next if sets.empty?
              maybe_good_variants[variant] = sets
            end
            if maybe_good_variants.size == 1
              canonical_variant = maybe_good_variants.keys[0]
            else
              p maybe_good_variants
              binding.pry
            end
          end
        end
      end
      if canonical_variant_source
        canonical_variant = versions.find{|k,v| k == canonical_variant_source}[1][key]
      end

      if canonical_variant
        @canonical[card_name][key] = canonical_variant
      else
        report_variants!(card_name, key, variants)
      end
    end
  end

  def canonical(card_name)
    return @canonical[card_name] if @canonical[card_name]
    raise "No canonical version for #{card_name}"
  end

  def verify!
    @versions.each do |card_name, versions|
      validate_and_report!(card_name, versions)
    end
  end
end
