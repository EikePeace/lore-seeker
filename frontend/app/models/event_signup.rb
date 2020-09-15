class EventSignup < ApplicationRecord
  validates_presence_of :event_slug
  validates_presence_of :snowflake

  def event
    Event.find_by(slug: self.event_slug)
  end

  def user
    User.find_or_create_by!(uid: self.snowflake)
  end

  def deck
    if self.sideboard.present?
      decklist = self.mainboard + "\n" + self.sideboard
    else
      decklist = self.mainboard
    end
    DeckParser.new($CardDatabase, decklist).deck
  end
end
