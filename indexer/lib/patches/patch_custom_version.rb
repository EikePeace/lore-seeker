class PatchCustomVersion < Patch
  def call
    each_set do |set|
      set["custom_version"] = set["meta"]["setVersion"]
    end
  end
end
