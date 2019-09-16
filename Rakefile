require "pathname"
require "fileutils"

def db
  @db ||= begin
    require_relative "search-engine/lib/card_database"
    CardDatabase.load
  end
end

task "default" => "spec"
task "test" => "spec"

# Run specs
task "spec" do
  Dir.chdir("search-engine") do
    sh "rspec"
  end
  Dir.chdir("frontend") do
    sh "rake test"
  end
end

desc "Generate index"
task "index" do
  sh "./indexer/bin/indexer"
end

desc "Fetch new mtgjson database"
task "mtgjson:fetch" do
  sh "indexer/bin/split_mtgjson", "http://mtgjson.com/json/AllSets-x.json"
end

desc "Fetch new mtgjson database, then revert known bad ones"
task "mtgjson:fetch:good" do
  sh "indexer/bin/split_mtgjson", "http://mtgjson.com/json/AllSets-x.json"
  # Unsets and Kamigawa block are broken, mostly flip/split cards
  # CP2 has long uncorrected typo
  # V17 has duplicate Brisela
  sh "git checkout data/sets/{UGL,UNH,UST,BOK,V17,CP2}.json"
end

desc "Fetch new mtgjson database and update index"
task "mtgjson:update" => ["mtgjson:fetch:good", "index"]

desc "Update penny dreadful banlist"
task "pennydreadful:update" do
  system "wget -q http://pdmtgo.com/legal_cards.txt -O index/penny_dreadful_legal_cards.txt"
end

desc "Update Canadian Highlander points list"
task "canlander:update" do
  require "json"
  require "nokogiri"
  require "open-uri"
  doc = Nokogiri::HTML(open("https://canadianhighlander.wordpress.com/rules-the-points-list-and-deck-construction/"))
  points_text = doc.css(".text_exposed_show p").last.text
  points_map = {}
  points_text.lines.each do |line|
    if line =~ /^(.*) – (\d+)\n?$/
      points_map[$1] = $2.to_i
    else
      raise "Failed to parse line in Canadian Highlander points list: #{line}"
    end
  end
  Pathname("index/canlander-points-list.json").write(points_map.to_json)
end

desc "Fetch Gatherer pics"
task "pics:gatherer" do
  pics = Pathname("frontend/public/cards")
  db.printings.each do |c|
    next unless c.multiverseid
    path = pics + Pathname("#{c.set_code}/#{c.number}.png")
    path.parent.mkpath
    next if path.exist?
    url = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{c.multiverseid}&type=card"
    puts "Downloading #{c.name} #{c.set_code} #{c.multiverseid}"
    system "wget", "-nv", "-nc", url, "-O", path.to_s
  end
end

desc "Connect links to HQ pics"
task "link:pics" do
  Pathname("frontend/public/cards_hq").mkpath
  if ENV["RAILS_ENV"] == "production"
    sources = Dir["/home/rails/magic-card-pics-hq-*/*/"]
  else
    sources = Dir["#{ENV['HOME']}/github/magic-card-pics-hq-*/*/"]
  end
  sources.each do |source|
    source = Pathname(source)
    set_name = source.basename.to_s
    target_path = Pathname("frontend/public/cards_hq/#{set_name}")
    next if target_path.exist?
    # p [target_path, source]
    target_path.make_symlink(source)
  end
end

desc "Fetch HQ pics"
task "pics:hq" do
  sh "./bin/fetch_hq_pics"
end

desc "Save HQ pics hashes"
task "pics:hq:save" do
  sh "./bin/save_hq_pics_hashes"
end

desc "Print basic statistics about card pictures"
task "pics:statistics" do
  sh "./bin/pics_statistics"
end

desc "List cards without pictures"
task "pics:missing" do
  sh "./bin/cards_without_pics"
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/Gemfile.lock",
    "frontend/log/development.log",
    "frontend/log/production.log",
    "frontend/log/test.log",
    "frontend/tmp",
    "search-engine/.respec_failures",
    "search-engine/coverage",
    "search-engine/Gemfile.lock",
  ].each do |path|
    system "trash", path if Pathname(path).exist?
  end
  Dir["**/.DS_Store"].each do |ds_store|
    FileUtils.rm ds_store
  end
end

desc "Fetch new Comprehensive Rules"
task "rules:update" do
  sh "bin/fetch_comp_rules"
  sh "bin/format_comp_rules"
end
