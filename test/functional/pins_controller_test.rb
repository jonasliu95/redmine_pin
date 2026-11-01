require File.expand_path('../test_helper', __dir__)

class PinsControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :email_addresses, :issues, :issue_statuses,
           :trackers, :projects_trackers, :enumerations, :members,
           :member_roles, :roles, :enabled_modules

  setup do
    @request.session[:user_id] = 2
  end

  def test_index_requires_login
    @request.session[:user_id] = nil
    get :index
    assert_response 302
  end

  def test_toggle_pins_then_unpins_visible_issue
    assert_difference('Pin.count', 1) { post :toggle, params: { issue_id: 1 }, xhr: true, format: 'js' }
    assert_response :success
    assert_difference('Pin.count', -1) { post :toggle, params: { issue_id: 1 }, xhr: true, format: 'js' }
  end

  def test_toggle_on_invisible_issue_returns_404_and_creates_nothing
    assert_no_difference('Pin.count') { post :toggle, params: { issue_id: hidden_issue.id }, xhr: true, format: 'js' }
    assert_response 404
  end

  def test_index_hides_pins_of_issues_no_longer_visible
    Pin.create!(user: User.find(2), issue: hidden_issue) # simulates a pin made before losing access
    get :index
    assert_response :success
    assert_select "#pinned-issue-#{hidden_issue.id}", 0
  end

  def test_disabled_plugin_blocks_index_and_toggle
    with_settings plugin_redmine_pin: { 'enabled' => '0' } do
      get :index
      assert_response 403
      post :toggle, params: { issue_id: 1 }, xhr: true, format: 'js'
      assert_response 403
    end
  end

  def test_index_unknown_view_mode_falls_back_to_list
    create_three_pins
    get :index, params: { view_mode: 'foo' }
    assert_response :success
    assert_select 'table.list.issues'
  end

  def test_index_grid_view
    create_three_pins
    get :index, params: { view_mode: 'grid' }
    assert_select '.pins-grid .pin-card', 3
  end

  def test_index_default_sort_is_newest_first
    create_three_pins(created_at: { 1 => 3.days.ago, 2 => 2.days.ago, 3 => 1.day.ago })
    get :index
    ids = css_select('tr[id^="pinned-issue-"]').map { |tr| tr['id'] }
    assert_equal %w[pinned-issue-3 pinned-issue-2 pinned-issue-1], ids
    assert_select 'select#order option[selected][value=desc]'
    assert_select 'select#sort option[selected][value=date]'
  end

  def test_index_every_sort_and_order_renders
    create_three_pins
    %w[date project status priority subject assignee bogus].product(%w[asc desc]).each do |sort, order|
      get :index, params: { sort: sort, order: order, group_by_project: '1' }
      assert_response :success, "#{sort}/#{order}"
    end
  end

  def test_toggle_js_replaces_button_with_unpin_state
    post :toggle, params: { issue_id: 1 }, xhr: true, format: 'js'
    assert_includes response.body, 'icon--pin-off'
  end

  def test_core_sort_label_is_not_overridden
    assert_equal 'Sort', I18n.t(:label_sort, locale: :en)
  end

  def test_toggle_survives_unique_index_race
    other_pin = Pin.create!(user: User.find(2), issue: Issue.find(1))
    Pin.stubs(:find_by).returns(nil) # our lookup ran before the other request committed
    Pin.any_instance.stubs(:valid?).returns(true) # both requests pass validation, one loses at the unique index
    post :toggle, params: { issue_id: 1 }, xhr: true, format: 'js'
    assert_response :success
    assert_equal 1, Pin.count
    assert other_pin.persisted?
  end

  private

  def create_three_pins(created_at: {})
    [1, 2, 3].each do |issue_id|
      pin = Pin.create!(user: User.find(2), issue: Issue.find(issue_id))
      pin.update_column(:created_at, created_at[issue_id]) if created_at[issue_id]
    end
  end

  def hidden_issue
    @hidden_issue ||= begin
      issue = Issue.where.not(id: Issue.visible(User.find(2))).first
      if issue.nil?
        project = Project.generate!(name: 'Hidden pin project', is_public: false)
        project.enabled_module_names = ['issue_tracking']
        project.trackers = [Tracker.find(1)]
        issue = Issue.generate!(project: project, tracker: Tracker.find(1), status: IssueStatus.find(1), author: User.find(1))
      end
      assert_not_nil issue
      issue
    end
  end
end
