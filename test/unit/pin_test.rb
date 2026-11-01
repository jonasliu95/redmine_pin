require File.expand_path('../test_helper', __dir__)

class PinTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :issues, :issue_statuses,
           :trackers, :projects_trackers, :enumerations, :members,
           :member_roles, :roles, :enabled_modules

  def test_issue_has_pins_association
    assert Issue.reflect_on_association(:pins)
    assert User.reflect_on_association(:pins)
  end

  def test_destroying_issue_removes_its_pins
    Pin.create!(user: User.find(2), issue: Issue.find(1))
    assert_difference 'Pin.count', -1 do
      Issue.find(1).destroy
    end
  end

  def test_destroying_user_removes_their_pins
    user = User.generate!
    Pin.create!(user: user, issue: Issue.find(1))
    assert_difference 'Pin.count', -1 do
      user.destroy
    end
  end

  def test_same_issue_cannot_be_pinned_twice_by_same_user
    Pin.create!(user: User.find(2), issue: Issue.find(1))
    assert_not Pin.new(user: User.find(2), issue: Issue.find(1)).valid?
  end
end
