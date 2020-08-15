class EventController < ApplicationController
  def index
    @title = "Events"
    @can_create = signed_in? && current_user.role_ids(custard_guild_id).include?(custard_organizer_role_id)
    all_events = Event.order(:start)
    started_events, @upcoming_events = all_events.partition{|e| e.start.present? && e.start <= DateTime.current }
    @past_events, @current_events = started_events.partition{|e| e.end.present? && e.end <= DateTime.current }
  end

  def show
    @event = Event.find_by(slug: params[:id])
    unless @event
      render_404
      return
    end
    @title = @event.name
    @can_edit = signed_in? && current_user.role_ids(custard_guild_id).include?(custard_organizer_role_id)
  end

  def create
    unless params[:slug].present?
      flash.danger = "Missing event URL."
      return redirect_to action: "index"
    end
    unless params[:slug] =~ /^[0-9a-z-]{1,32}$/
      flash.danger = "Invalid event URL. Only ASCII digits, lowercase letters, and hyphens allowed. Maximum 32 characters."
      return redirect_to action: "index"
    end
    if Event.where(slug: params[:slug]).first.present?
      flash.danger = "An event already exists at that URL."
      return redirect_to action: "index"
    end
    event = Event.create(slug: params[:slug], name: params[:name])
    redirect_to action: "edit", id: event.slug
  end

  def edit
    @event = Event.find_by(slug: params[:id])
    unless @event
      render_404
      return
    end
    @title = "Editing #{@event.name}"
    @can_edit = signed_in? && current_user.role_ids(custard_guild_id).include?(custard_organizer_role_id)
    return redirect_to(action: "show", id: @event.slug, alert: "You are not authorized to edit this event.") if !@can_edit
    if request.post?
      params.permit!
      @event.update!(params[:event])
      return redirect_to(action: "show", id: @event.slug)
    end
  end

  def set_state
    event = Event.find_by(slug: params[:id])
    unless event
      render_404
      return
    end
    can_edit = signed_in? && current_user.role_ids(custard_guild_id).include?(custard_organizer_role_id)
    return redirect_to(action: "show", id: event.slug, alert: "You are not authorized to edit this event.") if !can_edit
    event.state = params[:state].to_sym
    event.save!
    redirect_to action: "show", id: event.slug
  end
end
