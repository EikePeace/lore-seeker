require "json"
require "pathname"

class User < ApplicationRecord
  validates_presence_of :uid
  validates_uniqueness_of :uid

  def self.find_or_create_from_hash(hash)
    find_or_create_by!(uid: hash['uid'])
  end

  def profile_data
    user_path = Pathname.new("/usr/local/share/fenhl/lore-seeker/profiles").children.flat_map do |guild_dir|
      user_path = guild_dir + "#{self.uid}.json"
      if user_path.exist?
        [user_path]
      else
        []
      end
    end.first
    return JSON.load(user_path) if !user_path.nil?
  end

  def guild_profile_data(guild_id)
    user_path = Pathname.new("/usr/local/share/fenhl/lore-seeker/profiles") + guild_id.to_s + "#{self.uid}.json"
    return JSON.load(user_path) if user_path.exist?
  end

  def username
    profile = profile_data
    return profile["username"] if !profile.nil?
  end

  def discrim
    profile = profile_data
    return profile["discriminator"] if !profile.nil?
  end

  def role_ids(guild_id)
    profile = guild_profile_data(guild_id)
    if profile.nil?
      []
    else
      profile["roles"]
    end
  end

  def to_s
    if profile_data.nil?
      "deleted user"
    else
      "#{self.username}##{self.discrim}"
    end
  end
end
