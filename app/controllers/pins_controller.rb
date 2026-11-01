class PinsController < ApplicationController
  VIEW_MODES = %w[list grid].freeze
  SORTS = {
    'date' => 'pins.created_at',
    'project' => 'projects.name',
    'status' => 'issue_statuses.position',
    'priority' => 'enumerations.position',
    'subject' => 'issues.subject',
    'assignee' => 'users.lastname'
  }.freeze
  SORT_JOINS = {
    'project' => 'LEFT JOIN projects ON issues.project_id = projects.id',
    'status' => 'LEFT JOIN issue_statuses ON issues.status_id = issue_statuses.id',
    'priority' => 'LEFT JOIN enumerations ON issues.priority_id = enumerations.id',
    'assignee' => 'LEFT JOIN users ON issues.assigned_to_id = users.id'
  }.freeze

  before_action :require_login
  before_action :require_plugin_enabled
  before_action :find_issue, only: [:toggle]

  def index
    @pins = Pin.where(user_id: User.current.id, issue_id: Issue.visible.select(:id)).
              joins(:issue).
              includes(issue: [:project, :status, :priority, :assigned_to])

    @view_mode = VIEW_MODES.include?(params[:view_mode]) ? params[:view_mode] : 'list'
    @group_by_project = params[:group_by_project] == '1'
    @sort = SORTS.key?(params[:sort]) ? params[:sort] : 'date'
    @order = params[:order] == 'asc' ? 'asc' : 'desc'

    if (join = SORT_JOINS[@sort])
      @pins = @pins.joins(join)
    end
    @pins = @pins.order(sort_expression)

    if @group_by_project
      @pins_by_project = @pins.group_by { |p| p.issue.project }
    end
  end

  def toggle
    pin = Pin.find_by(user_id: User.current.id, issue_id: @issue.id)
    if pin
      pin.destroy
      @pinned = false
    else
      begin
        Pin.create!(user: User.current, issue: @issue)
      rescue ActiveRecord::RecordNotUnique
        # Another request pinned the same issue between our lookup and insert.
      end
      @pinned = true
    end
    
    respond_to do |format|
      format.js
      format.html { redirect_back_or_default issue_path(@issue) }
    end
  end

  private

  def sort_expression
    if @sort == 'assignee'
      "users.lastname #{@order}, users.firstname #{@order}"
    else
      "#{SORTS[@sort]} #{@order}"
    end
  end

  def require_plugin_enabled
    render_403 unless RedminePin.enabled?
  end

  def find_issue
    @issue = Issue.visible.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
