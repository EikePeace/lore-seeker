require "unicode_utils"
class ConditionForeign < ConditionSimple
  def initialize(lang, query)
    @lang = lang.downcase
    # Support both Gatherer and MCI naming conventions
    @lang = "ct" if @lang == "tw"
    @lang = "cs" if @lang == "cn"
    @query = hard_normalize(query)
  end

  def match?(card)
    if @lang == "foreign"
      foreign_names = card.foreign_names_normalized.values.flatten
    else
      foreign_names = card.foreign_names_normalized[@lang] || []
    end
    foreign_names.any?{|n|
      n.include?(@query)
    }
  end

  def to_s
    "#{@lang}:#{maybe_quote(@query)}"
  end

  private

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end
end
