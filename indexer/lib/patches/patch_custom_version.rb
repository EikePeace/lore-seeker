class PatchCustomVersion < Patch
  def call
    each_set do |set|
      set["custom_version"] = set["meta"]["setVersion"] # not deleting set["meta"] here just in case upstream starts using it in the future
    end
  end
end
