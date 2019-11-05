module Color
  Names = {
    "white" => "w",
    "blue" => "u",
    "black" => "b",
    "red" => "r",
    "green" => "g",

    "azorius" => "wu",
    "dimir" => "ub",
    "rakdos" => "br",
    "gruul" => "rg",
    "selesnya" => "gw",

    "boros" => "wr",
    "simic" => "ug",
    "orzhov" => "bw",
    "izzet" => "ru",
    "golgari" => "gb",

    "bant" => "gwu",
    "esper" => "wub",
    "grixis" => "ubr",
    "jund" => "brg",
    "naya" => "rgw",

    "abzan" => "wbg",
    "jeskai" => "urw",
    "sultai" => "bgu",
    "mardu" => "rwb",
    "temur" => "gur",
  }

  def self.color_identity_name(color_identity)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_identity = names.map{|c,cv| color_identity.include?(c) ? cv : nil}.compact
    #TODO canonical color order
    case color_identity.size
    when 0
      "colorless"
    when 1, 2
      color_identity.join(" and ")
    when 3
      a, b, c = color_identity
      "#{a}, #{b}, and #{c}"
    when 4
      a, b, c, d = color_identity
      "#{a}, #{b}, #{c}, and #{d}"
    when 5
      "all colors"
    else
      raise
    end
  end

  def self.color_indicator_name(indicator)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_indicator = names.map{|c,cv| indicator.include?(c) ? cv : nil}.compact
    #TODO canonical color order
    case color_indicator.size
    when 5
      # It got removed with Sphinx of the Guildpact printing (RNA)
      nil
    when 1, 2
      color_indicator.join(" and ")
    when 3
      # Nicol Bolas from M19
      a, b, c = color_indicator
      "#{a}, #{b}, and #{c}"
    when 4
      # No such cards
      a, b, c, d = color_indicator
      "#{a}, #{b}, #{c}, and #{d}"
    when 0
      # devoid and Ghostfire - for some reason they use rules text, not color indicator
      # "colorless"
      nil
    end
  end
end
