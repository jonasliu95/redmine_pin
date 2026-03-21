class Pin < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  
  validates_presence_of :user, :issue
  validates_uniqueness_of :issue_id, scope: :user_id
end
