class FormatCanadianHighlander < FormatVintage
  def legality(card)
    status = super(card)
    return status if status != "legal"
    if PointsList.has_key?(card)
      "restricted-#{PointsList[card]}"
    else
      status
    end
  end

  def format_pretty_name
    "Canadian Highlander"
  end

  def self.load_points_list
    points_file = (Pathname(__dir__) + "../../../index/canlander-points-list.json")
    JSON.parse(points_file.read)
  end

  PointsList = load_points_list
end
