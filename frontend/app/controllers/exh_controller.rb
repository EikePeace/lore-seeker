class ExhSorter
  def initialize(ech)
    @ech = ech
  end

  def sort(results)
    results.sort_by do |c|
      [
        -c.num_exh_votes,
        @ech.legality(c).start_with?("banned"),
        @ech.legality(c).start_with?("restricted"),
        !c.commander?,
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

class ExhController < ApplicationController
  def index
    redirect_to(controller: "format", action: "show", id: "elder-xmage-highlander")
  end

  def todo
    @title = "EXH card todo list"
    @ech = Format["elder cockatrice highlander"].new
    @exh = Format["elder xmage highlander"].new
    #TODO special section for reprints of implemented cards, if any
    search = "(f:ech or banned:ech) -f:exh sort:oldall" #TODO replace “sort:oldall” with sorter override below, include banned cards?
    query = Query.new(search)
    query.sorter = ExhSorter.new(@ech)
    results = $CardDatabase.search(query)
    @cards = results.card_groups.map do |printings|
      choose_best_printing(printings)
    end
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
end
