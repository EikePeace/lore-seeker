class DownloadsController < ApplicationController
  def index
    @title = "Downloads"
    version_file = (Pathname(__dir__) + "../../../data/bcb-version.txt")
    @bcb_version = version_file.exist? ? version_file.read.strip : "unknown"
    version_file = (Pathname(__dir__) + "../../../data/xmage-version.txt")
    @xmage_version = version_file.exist? ? version_file.read.strip : "unknown"
  end
end
