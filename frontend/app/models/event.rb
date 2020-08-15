class Event < ApplicationRecord
  validates_presence_of :slug
  validates_uniqueness_of :slug

  def format
    Format["custom standard"].new
  end

  def official?
    self.organizer.nil?
  end

  def organizer
    nil #TODO
  end

  def rel_pretty
    case self.rel
    when "reg"
      "Regular"
    when "comp"
      "Competitive"
    when "prof"
      "Professional"
    else
      self.rel
    end
  end

  def signups
    EventSignup.where(event_slug: self.slug)
  end

  def state
    if self.end <= DateTime.current
      :ended
    elsif self.start <= DateTime.current
      :bracket
    elsif self.sideboard_submissions <= DateTime.current
      :sideboards
    elsif self.mainboard_submissions <= DateTime.current
      :mainboards
    elsif self.announcement <= DateTime.current
      :announced
    else
      :setup
    end
  end

  def state=(value)
    case value
    when :announced
      self.announcement = DateTime.current
    when :mainboards
      self.mainboard_submissions = DateTime.current
    when :sideboards
      self.sideboard_submissions = DateTime.current
    when :bracket
      self.start = DateTime.current
    when :ended
      self.end = DateTime.current
    end
  end

  def announcement_date
    get_date(self.announcement)
  end

  def announcement_time
    get_time(self.announcement)
  end

  def announcement_date=(value)
    self.announcement = update_date(self.announcement, value)
  end

  def announcement_time=(value)
    self.announcement = update_time(self.announcement, value)
  end

  def mainboard_submissions_date
    get_date(self.mainboard_submissions)
  end

  def mainboard_submissions_time
    get_time(self.mainboard_submissions)
  end

  def mainboard_submissions_date=(value)
    self.mainboard_submissions = update_date(self.mainboard_submissions, value)
  end

  def mainboard_submissions_time=(value)
    self.mainboard_submissions = update_time(self.mainboard_submissions, value)
  end

  def sideboard_submissions_date
    get_date(self.sideboard_submissions)
  end

  def sideboard_submissions_time
    get_time(self.sideboard_submissions)
  end

  def sideboard_submissions_date=(value)
    self.sideboard_submissions = update_date(self.sideboard_submissions, value)
  end

  def sideboard_submissions_time=(value)
    self.sideboard_submissions = update_time(self.sideboard_submissions, value)
  end

  def start_date
    get_date(self.start)
  end

  def start_time
    get_time(self.start)
  end

  def start_date=(value)
    self.start = update_date(self.start, value)
  end

  def start_time=(value)
    self.start = update_time(self.start, value)
  end

  def end_date
    get_date(self.end)
  end

  def end_time
    get_time(self.end)
  end

  def end_date=(value)
    self.end = update_date(self.end, value)
  end

  def end_time=(value)
    self.end = update_time(self.end, value)
  end

  private

  def get_date(value)
    value.strftime("%Y-%m-%d")
  end

  def get_time(value)
    value.strftime("%H:%M:%S")
  end

  def update_date(prev, value)
    if prev.present?
      prev_time = prev.seconds_since_midnight.seconds
    else
      prev_time = 0.seconds
    end
    DateTime.strptime(value, "%Y-%m-%d") + prev_time
  end

  def update_time(prev, value)
    if prev.present?
      prev_date = prev.to_date
    else
      prev_date = Date.current # should never be called but just in case
    end
    prev_date.to_datetime + DateTime.strptime(value, "%H:%M:%S").seconds_since_midnight.seconds
  end
end
