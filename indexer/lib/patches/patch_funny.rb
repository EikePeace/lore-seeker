class PatchFunny < Patch
  def call
    errata_sets = @sets.select{|set| set["type"] == "errata"}.map{|set| set["code"].downcase}
    funny_sets = %W[unh ugl pcel hho parl prel ust pust ppc1 htr htr17 pal04 h17 j17 tbth tdag tfth thp1 thp2 thp3]
    each_card do |name, printings|
      funny = printings.all?{|card| funny_sets.include?(card["set_code"]) || errata_sets.include?(card["set_code"]) }

      if funny
        printings.each do |printing|
          printing["funny"] = true
        end
      end
    end
  end
end
