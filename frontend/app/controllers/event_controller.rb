class EventController < ApplicationController
  def index
    @title = "Events"
  end

  def cssl_index
    @title = "Custom Standard Sealed League"
  end
end
