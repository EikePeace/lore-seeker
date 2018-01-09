BanList.for_format("standard") do
  change(
    "1995-05-01",
    nil,
    "Balance" => "restricted",
  )

  change(
    "1996-02-01",
    nil,
    "Mind Twist" => "banned",
    "Black Vise" => "restricted",
  )

  change(
    "1996-07-01",
    nil,
    "Land Tax" => "restricted",
  )

  change(
    "1996-10-01",
    nil,
    "Hymn to Tourach" => "restricted",
    "Strip Mine" => "restricted",
  )

  change(
    "1997-01-01",
    nil,
    "Balance" => "banned",
    "Black Vise" => "banned",
    "Hymn to Tourach" => "banned",
    "Land Tax" => "banned",
    "Strip Mine" => "banned",
  )

  change(
    "1997-07-01",
    nil,
    "Zuran Orb" => "banned",
  )

  change(
    "1999-01-01",
    nil,
    "Tolarian Academy" => "banned",
    "Windfall" => "banned",
  )

  change(
    "1999-04-01",
    nil,
    "Dream Halls" => "banned",
    "Earthcraft" => "banned",
    "Fluctuator" => "banned",
    "Lotus Petal" => "banned",
    "Memory Jar" => "banned",
    "Recurring Nightmare" => "banned",
    "Time Spiral" => "banned",
  )

  change(
    "1999-07-01",
    "http://web.archive.org/web/20111121212434/http://www.crystalkeep.com/magic/rules/dci/update-990601.txt",
    "Mind Over Matter" => "banned",
  )

  change(
    "2004-06-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20040601a",
    "Skullclamp" => "banned",
  )

  change(
    "2005-03-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20050301a",
    "Ancient Den" => "banned",
    "Arcbound Ravager" => "banned",
    "Darksteel Citadel" => "banned",
    "Disciple of the Vault" => "banned",
    "Great Furnace" => "banned",
    "Seat of the Synod" => "banned",
    "Tree of Tales" => "banned",
    "Vault of Whispers" => "banned",
  )

  change(
    "2011-07-01",
    "https://magic.wizards.com/en/articles/archive/feature/june-20-2011-dci-banned-restricted-list-announcement-2011-06-20",
    "Jace, the Mind Sculptor" => "banned",
    "Stoneforge Mystic" => "banned",
    # OK, this is awkward, was it ever "unbanned" ?
    # it just rotated out of Standard and banlist, then got reprinted as legal
    "Darksteel Citadel" => "legal",
  )

  change(
    "2017-01-20",
    "https://magic.wizards.com/en/articles/archive/news/january-9-2017-banned-and-restricted-announcement-2017-01-09",
    "Emrakul, the Promised End" => "banned",
    "Reflector Mage" => "banned",
    "Smuggler's Copter" => "banned",
  )

  change(
    "2017-04-28",
    "https://magic.wizards.com/en/articles/archive/news/addendum-april-24-2017-banned-and-restricted-announcement-2017-04-26",
    "Felidar Guardian" => "banned",
  )

  change(
    "2017-06-19",
    "https://magic.wizards.com/en/articles/archive/feature/june-13-2017-banned-and-restricted-announcement-2017-06-13",
    "Aetherworks Marvel" => "banned",
  )
end
