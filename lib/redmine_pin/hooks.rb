module RedminePin
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head, partial: 'hooks/redmine_pin/html_head'
    render_on :view_issues_show_details_bottom, partial: 'hooks/redmine_pin/issue_show_details_bottom'
  end
end
