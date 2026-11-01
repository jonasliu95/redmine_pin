class PinsController < ApplicationController
  before_action :require_login
  before_action :require_plugin_enabled
  before_action :find_issue, only: [:toggle]

  def index
    @pins = Pin.where(user_id: User.current.id, issue_id: Issue.visible.select(:id)).
              joins(:issue).
              includes(issue: [:project, :status, :priority, :assigned_to])
    
    # Handle view modes (list/grid)
    @view_mode = params[:view_mode] || 'list'
    
    # Support grouping by project
    @group_by_project = params[:group_by_project] == '1'
    
    # Basic sorting
    sort_by = params[:sort] || 'created_at'
    sort_order = params[:order] == 'desc' ? 'desc' : 'asc'
    
    case sort_by
    when 'date'
      @pins = @pins.order("pins.created_at #{sort_order}")
    when 'project'
      @pins = @pins.joins(:issue).joins("LEFT JOIN projects ON issues.project_id = projects.id").order("projects.name #{sort_order}")
    when 'status'
      @pins = @pins.joins(:issue).joins("LEFT JOIN issue_statuses ON issues.status_id = issue_statuses.id").order("issue_statuses.position #{sort_order}")
    when 'priority'
      @pins = @pins.joins(:issue).joins("LEFT JOIN enumerations ON issues.priority_id = enumerations.id").order("enumerations.position #{sort_order}")
    when 'subject'
      @pins = @pins.joins(:issue).order("issues.subject #{sort_order}")
    when 'assignee'
      @pins = @pins.joins(:issue).joins("LEFT JOIN users ON issues.assigned_to_id = users.id").order("users.lastname #{sort_order}, users.firstname #{sort_order}")
    else
      @pins = @pins.order("pins.created_at #{sort_order}")
    end
    
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

  def require_plugin_enabled
    render_403 unless RedminePin.enabled?
  end

  def find_issue
    @issue = Issue.visible.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
