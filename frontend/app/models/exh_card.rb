class ExhCard < ApplicationRecord
  def voters
    self.voter_ids.map{|voter_id| User.find_by(uid: voter_id) }
  end

  def add_vote!(user)
    self.voter_ids.push(user.uid)
    self.save!
  end

  def remove_vote!(user)
    self.voter_ids.reject!{|voter_id| voter_id == user.uid }
    self.save!
  end
end
