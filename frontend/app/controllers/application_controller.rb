class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # isn't there a standard way to do this already?
  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end

  def render_403
    render file: "#{Rails.root}/public/403.html", layout: false, status: 403
  end

  # Lore Seeker extension: bootstrap flash types
  add_flash_types :danger, :warning, :success, :info

  protected

  def current_user
    @current_user ||= User.find_by(uid: session[:user_id])
  end

  def dev?
    request.host_with_port == "dev.lore-seeker.cards"
  end

  def signed_in?
    !!current_user
  end

  def exh_card(card)
    card = card.respond_to?(:main_front) ? card.main_front : card
    card_name = card.respond_to?(:name) ? card.name : card
    ExhCard.find_or_create_by!(name: card_name)
  end

  def color_identity_name(color_identity)
    Color.color_identity_name(color_identity)
  end

  def indef_article(text, caps: false)
    # may not be correct for words starting with <u> pronounced as [ju]
    if "AEIOUaeiou".include?(text[0])
      caps ? "An" : "an"
    else
      caps ? "A" : "a"
    end
  end

  def aware_datetime_field(form, field_name)
    tag.div(class: "input-group") do
      form.date_field("#{field_name}_date", class: "form-control") +
      form.date_field("#{field_name}_time", class: "form-control", step: 1) +
      tag.div(class: "input-group-append") do
        tag.div(class: "input-group-text") do
          Time.zone.name #TODO allow modifying timezone?
        end
      end
    end

    form.datetime_select
  end

  def custard_guild_id
    481200347189084170
  end

  def custard_organizer_role_id
    481201599335628800
  end

  helper_method :current_user, :dev?, :signed_in?, :exh_card
  helper_method :color_identity_name, :indef_article, :aware_datetime_field
  helper_method :custard_guild_id, :custard_organizer_role_id

  def current_user=(user)
    @current_user = user
    if user.nil?
      session.delete(:user_id)
    else
      session[:user_id] = user.uid
    end
  end

  private

  def paginate_by_set(printings, page)
    printings
             .sort_by{|c| [-c.release_date_i, c.set_name, c.name]}
             .group_by(&:set)
             .to_a
             .paginate(page: page, per_page: 10)
  end
end
