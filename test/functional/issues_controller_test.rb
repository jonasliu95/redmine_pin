require File.expand_path('../test_helper', __dir__)

class IssuesControllerTest < Redmine::ControllerTest
  tests IssuesController

  fixtures :projects, :users, :email_addresses, :issues, :issue_statuses,
           :trackers, :projects_trackers, :enumerations, :members,
           :member_roles, :roles, :enabled_modules, :journals, :journal_details

  setup do
    @request.session[:user_id] = 2
  end

  def test_issue_page_renders_svg_pin_button
    get :show, params: { id: 1 }
    assert_select 'a#redmine-pin-toggle-btn svg use[href*="plugin_assets/redmine_pin/"][href$="#icon--pin"]'
  end

  def test_issue_page_button_is_localized
    User.find(2).update_column(:language, 'lt')
    get :show, params: { id: 1 }
    assert_select 'a#redmine-pin-toggle-btn', text: /#{Regexp.escape(I18n.t(:button_redmine_pin_pin, locale: :lt))}/
  end
end
