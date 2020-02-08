class DownloadsController < ApplicationController
  def index
    @title = "Downloads"
    version_file = (Pathname(__dir__) + "../../../data/bcb-version.txt")
    @version = version_file.exist? ? version_file.read : "unknown"
  end
end
