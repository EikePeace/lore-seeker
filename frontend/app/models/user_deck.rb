class UserDeck < ApplicationRecord
  belongs_to :user, optional: true
  validates_presence_of :name, :format, :public

  def cards
    format_board(:mainboard)
  end

  def sideboard
    format_board(:sideboard)
  end

  def commandboard
    format_board(:commandboard)
  end

  def number_of_mainboard_cards
    cards.map(&:first).inject(0, &:+)
  end

  def number_of_sideboard_cards
    sideboard.map(&:first).inject(0, &:+)
  end

  def number_of_commandboard_cards
    commandboard.map(&:first).inject(0, &:+)
  end

  def number_of_total_cards
    number_of_mainboard_cards + number_of_sideboard_cards + number_of_commandboard_cards
  end

  def physical_cards
    [*@cards.map(&:last), *@sideboard.map(&:last), *@commandboard.map(&:last)].uniq
  end

  def inspect
    "UserDeck<#{self.name} - #{self.user}>"
  end

  def to_s
    self.name
  end

  def type
    "user"
  end

  private

  def format_board(board)
    #TODO [count, set_code, collector_number]
  end
end
