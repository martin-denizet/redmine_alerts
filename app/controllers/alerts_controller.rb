class AlertsController < ApplicationController
  unloadable
  before_filter :authorize_global

  def index
    @my_alerts = Alert.find(:all,
      :conditions => ["("+
          "(#{Alert.table_name}.alert_watchers=1 AND #{Watcher.table_name}.user_id=?) OR "+
          "(#{Alert.table_name}.alert_project_members=1 AND #{Member.table_name}.user_id=?) OR" +
          "(#{AlertSubscribers.table_name}.user_id=?)
    )"+
          " AND #{Alert.table_name}.sent_on IS NULL",
        User.current.id, User.current.id, User.current.id
      ],
      :include => [ :issue, :author, :subscribers ],
      :joins => "LEFT OUTER JOIN #{Member.table_name} ON #{Member.table_name}.project_id = #{Issue.table_name}.project_id"+
        " LEFT OUTER JOIN #{Watcher.table_name} ON #{Watcher.table_name}.watchable_id = #{Issue.table_name}.id AND (#{Watcher.table_name}.watchable_type='Issue')",
      :order => "#{Alert.table_name}.date ASC")

    @others_alerts=nil

    if User.current.allowed_to?({ :controller => 'alerts', :action => ':index_all' }, nil, :global => true)
      @others_alerts = Alert.find(:all,
        :conditions => ["("+
            "(#{Alert.table_name}.alert_watchers=1 AND #{Watcher.table_name}.user_id!=?) AND "+
            "(#{Alert.table_name}.alert_project_members=1 AND #{Member.table_name}.user_id!=?) AND " +
            "(#{AlertSubscribers.table_name}.user_id!=?)
    )"+
            " AND #{Alert.table_name}.sent_on IS NULL",
          User.current.id, User.current.id, User.current.id
        ],
        :include => [ :issue, :author, :subscribers ],
        :joins => "LEFT OUTER JOIN #{Member.table_name} ON #{Member.table_name}.project_id = #{Issue.table_name}.project_id"+
          " LEFT OUTER JOIN #{Watcher.table_name} ON #{Watcher.table_name}.watchable_id = #{Issue.table_name}.id AND (#{Watcher.table_name}.watchable_type='Issue')",
        :order => "#{Alert.table_name}.date ASC")
    end
  end

  def render_update
    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        @alert = Alert.new if @alert==nil
        @alerts=get_alerts_by_issue(@issue.id)
        render (:update) { |page|
          page.replace_html 'alerts', :partial => 'alerts/alerts', :locals => {:alerts => @alerts, 
            #:issue=>@issue,
            :alert=>@alert}
        }
      }
    end
  end

  def render_edit
    @issue=Issue.find(@alert.issue_id) if @issue==nil and @alert != nil
    #    @alert = Alert.new
    render_update
  end

  def subscribe

    @issue = Issue.find(params[:issue_id])
    @alert = Alert.find(params[:id])
    
    subscription = AlertSubscribers.new
    subscription.user_id = User.current.id
    subscription.alert_id = @alert.id
    subscription.save

    render_update
  end

  def unsubscribe

    @alert = Alert.find(params[:id])

    AlertSubscribers.destroy_all(:user_id=>User.current.id,:alert_id=>@alert.id)

    render_update
  end

  def edit
    @alert = Alert.find(params[:id])

    if request.post? and params[:alert]!=nil
      begin
        @alert.date=get_date_from_params
        @alert.comment=params[:alert][:comment]
        @alert.alert_watchers=params[:alert][:alert_watchers]
        @alert.alert_project_members=params[:alert][:alert_project_members]
        unless flash[:error]
          @alert.save
          render_update
        else
          render_edit
        end
      rescue
        render_edit
      end
    else
      render_edit

    end
  end

  def edit_own
    @alert = Alert.find(params[:id])
    if @alert.author_id==User.current.id
      edit
    else
      flash.now[:error]=l(:alert_error_edit_only_own)
      render_edit
    end
  end


  def new
    if request.post?
      begin
        @issue=Issue.find(params[:issue_id])
        @alert=Alert.new({
            :date=>get_date_from_params,
            :author_id=>User.current.id,
            :issue_id=>@issue.id,
            :created_on=>DateTime.now,
            :comment=>params[:alert][:comment],
            :alert_watchers=>params[:alert][:alert_watchers],
            :alert_project_members=>params[:alert][:alert_project_members]

          })
        RAILS_DEFAULT_LOGGER.info "Date:"+get_date_from_params.to_s
        unless flash[:error]
          @alert.save
          subscription=AlertSubscribers.new({
              :user_id=>User.current.id,
              :alert_id=>@alert.id
            })
          subscription.save
          @alert = Alert.new()
        end
        render_update
      rescue
        render_update
      end
    end
  end

  def destroy
    @alert = Alert.find(params[:id])
    issue_id=@alert.issue_id
    @issue = Issue.find(issue_id)
    @alert.destroy

    render_update
  end

  def destroy_own
    @alert = Alert.find(params[:id])
    issue_id=@alert.issue_id
    @issue = Issue.find(issue_id)
    if @alert.author_id==User.current.id
      @alert.destroy
    else
      flash.now[:error]=l(:alert_error_delete_only_own)
    end
    render_update
  end

  protected
  def get_date_from_params
    calculated_date=nil
    if params[:alert][:"date(1i)"] != nil
      #Absolute date
      calculated_date = DateTime.civil(params[:alert][:"date(1i)"].to_i,
        params[:alert][:"date(2i)"].to_i,
        params[:alert][:"date(3i)"].to_i,params[:alert][:"date(4i)"].to_i,
        params[:alert][:"date(5i)"].to_i)
    else
      #Relative date
      value=params[:alert][:duration].to_i
      if value == 0
        flash.now[:error] = l(:alert_error_incorrect_duration)
      end
      ref_date=DateTime.now

      case(params[:alert][:method].to_i)
      when 2
        check_start_date_exists(@issue)
        ref_date=@issue.start_date
        value=-value
      when 3
        check_due_date_exists(@issue)
        ref_date=@issue.due_date
        value=-value
      when 4
        check_start_date_exists(@issue)
        ref_date=@issue.start_date
      when 5
        check_due_date_exists(@issue)
        ref_date=@issue.due_date
      else
      end

      case(params[:alert][:unit].to_i)
      when 1
        calculated_date = ref_date + value.minute
      when 2
        calculated_date = ref_date + value.hour
      when 3
        calculated_date = ref_date + value.days
      when 4
        calculated_date = ref_date + value.week
      when 5
        calculated_date = ref_date + value.month
      when 6
        calculated_date = ref_date + value.year
      else
        RAILS_DEFAULT_LOGGER.error "Error:"+params[:alert][:unit].to_s
      end

    end
    if calculated_date<DateTime.now
      flash.now[:error] = l(:alert_error_date_past)
    end

    calculated_date
  end

  def check_start_date_exists(issue)
    unless issue.start_date
      flash.now[:error] = l(:alert_error_no_start_date)
      raise 'Start date is nil'
    end
  end
  def check_due_date_exists(issue)
    unless issue.due_date
      flash.now[:error] = l(:alert_error_no_due_date)
      raise 'Due date is nil'
    end
  end
end
