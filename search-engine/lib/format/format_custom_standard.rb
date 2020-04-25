class FormatCustomStandard < FormatStandard
  def format_pretty_name
    "Custom Standard"
  end

  def include_custom_sets?
    true
  end

  def rotation_schedule_with_multiplayer
    {
      "2016-12-08" => [["ayr", "dms", "ank"], []],
      "2017-04-21" => [["ayr", "dms", "ank", "ldo", "tsl"], []],
      "2017-08-06" => [["dms", "ank", "ldo", "tsl", "vln"], []],
      "2017-11-05" => [["dms", "ldo", "tsl", "vln", "jan"], []],
      "2018-01-21" => [["ldo", "tsl", "vln", "jan", "hlw"], []],
      "2018-04-15" => [["ldo", "vln", "jan", "hlw", "cc18"], []],
      "2018-10-25" => [["vln", "jan", "hlw", "cc18", "rak"], []],
      "2019-02-08" => [["jan", "hlw", "cc18", "rak", "eau"], []],
      "2019-05-29" => [["jan", "hlw", "cc18", "rak", "eau", "sou"], []],
      "2019-08-26" => [["jan", "hlw", "cc18", "rak", "eau", "sou", "net"], []],
      "2020-01-01" => [["rak", "eau", "sou", "net", "vst"], []],
      "2020-05-01" => [["rak", "eau", "sou", "net", "vst", "src"], ["mhlw"]],
    }
  end

  def rotation_schedule
    rotation_schedule_with_multiplayer.map{|date, val| [date, val.first]}.to_h
  end
end
