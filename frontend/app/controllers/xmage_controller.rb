require "json"
require "open-uri"

class TodoSorter
  def initialize(formats)
    @formats = formats
  end

  def sort(results)
    results.sort_by do |c|
      [
        -c.num_exh_votes
      ] + @formats.map{|format| (format.legality(c).nil? ? 3 : format.legality(c).start_with?("banned") ? 2 : (format.legality(c).start_with?("restricted") ? 1 : 0))} + [
        c.commander? ? 0 : (c.brawler? ? 1 : 2),
        c.release_date_i,
        c.color_identity.size,
        c.default_sort_index
      ]
    end
  end

  def warnings
    []
  end
end

class XmageController < ApplicationController
  def index
    redirect_to(controller: "downloads", action: "index", anchor: "xmage")
  end

  def xmage_config # can't be named config because of https://github.com/rails/rails/issues/29217
    today_config = JSON.load(open("http://xmage.today/config.json"))
    base_url = dev? ? "https://dev.lore-seeker.cards" : "https://lore-seeker.cards"
    version_file = (Pathname(__dir__) + "../../../data/xmage-version.txt")
    version = version_file.exist? ? version_file.read.strip : "unknown"
    render json: {
      java: today_config["java"],
      XMage: {
        version: version,
        location: "#{base_url}/download/xmage-update.zip",
        locations: [],
        full: "#{base_url}/download/xmage.zip",
        torrent: "",
        images: "",
        Launcher: today_config["XMage"]["Launcher"]
      }
    }
  end

  def news
    @title = "new XMage cards"
    @entries = []
    date = dev? ? Date.new(2019, 9, 24) : Date:new(2020, 3, 3)
    cards = Set[]
    until date > Date.today do
      if date > Date.new(2019, 9, 24) and $XmageCache.get(date).nil?
        date += 1
        next
      end
      query = Query.new("st:custom is:mainfront game:xmage", dev: dev?)
      query.cond.metadata! :time, date
      results = $CardDatabase.search(query).card_groups.map do |printings|
        with_best_printing(printings).first
      end
      next_cards = results.map(&:card).to_set
      if next_cards != cards
        @entries.insert(0, [date, results.reject{|best_printing| cards.include?(best_printing.card)}.sort])
        cards = next_cards
      end
      date += 1
    end
  end

  def todo
    @title = "XMage card todo list"
    @formats = [
      Format["custom standard"].new,
      Format["custom brawl"].new,
      Format["elder custom highlander"].new,
      Format["custom eternal"].new
    ]
    page = [1, params[:page].to_i].max
    #TODO special section for reprints of implemented cards, if any
    search = "st:custom is:mainfront -game:xmage"
    query = Query.new(search, dev: dev?)
    query.sorter = TodoSorter.new(@formats)
    results = $CardDatabase.search(query)
    @cards = results.card_groups.map do |printings|
      with_best_printing_and_rotation_info(printings)
    end
    @cards = @cards.paginate(page: page, per_page: 100)
    #TODO special section for vanilla and french vanilla cards, if any
  end

  def vote
    return redirect_to("/auth/discord") unless signed_in?
    card = exh_card(params[:name])
    if card.voters.include?(current_user)
      card.remove_vote!(current_user)
    else
      card.add_vote!(current_user)
    end
    redirect_back fallback_location: {controller: "card", action: "index", params: {q: card.name}}
  end

  def exh_index
    redirect_to(controller: "format", action: "show", id: "elder-xmage-highlander")
  end

  def exh_news
    redirect_to(action: "news")
  end

  def exh_todo
    redirect_to(action: "todo")
  end

  private

  def with_best_printing(printings)
    best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
    [best_printing, printings]
  end

  def with_best_printing_and_rotation_info(printings)
    best_printing, printings = with_best_printing(printings)
    exh_card = ExhCard.find_by(name: best_printing.name)
    [best_printing, printings, exh_card && exh_card.rotation]
  end
end
