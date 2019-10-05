class CardController < ApplicationController
  def vote
    redirect_to(controller: "session", action: "create") unless signed_in?
    card = exh_card(params[:name])
    if card.voters.include?(current_user)
      card.remove_vote!(current_user)
    else
      card.add_vote!(current_user)
    end
    redirect_back fallback_location: {controller: "card", action: "index", params: {q: card.name}}
  end
end
