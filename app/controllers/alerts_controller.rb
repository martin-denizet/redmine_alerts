class AlertsController < ApplicationController
  unloadable

  def index

  end

  #  def add_watchers_in_alert
  #    @issue=Issue.find(params[:issue_id])
  #    @days_in=params[:days_in]
  #    @alert_date=days_in.days.from_now
  #
  #    #if User.current.allowed_to?(:edit_issues, @issue.project) then
  #
  #    @alert=Alert(:issue_id=>@issue.id,:date=>@alert_date)
  #
  #
  #
  #    #else
  #    #render_403
  #    #end
  #
  #
  #    render(:layout=>false)
  #  end

  def render_update
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        @alerts=Alert.find(:all,:conditions=>["issue_id=?",@issue.id])
        render :update do |page|
          page.replace_html 'alerts', :partial => 'alerts/alerts', :locals => {:alerts => @alerts, :issue=>@issue}
        end
      end
    end
  end

  def subscribe

    @issue=Issue.find(params[:issue_id])
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

  def new
    if request.post?
      @issue=Issue.find(params[:issue_id])
      @alert=Alert.new({
          :date=>get_date_from_params,
          :author_id=>User.current.id,
          :issue_id=>@issue.id,
          :created_on=>DateTime.now

        })
      @alert.save
      render_update
    end
  end

  def get_date_from_params
    value=params[:alert][:duration].to_i
    ref_date=DateTime.now

    puts "hhhhhhhhhhhhey"+ref_date.to_s
    case(params[:alert][:method])
    when 2
      ref_date=@issue.due_date
    else
    end
    
    case(params[:alert][:unit].to_i)
    when 1
      ref_date += value.minute
    when 2
      ref_date += value.minute
    when 3
      ref_date += value.days
    when 4
      ref_date += value.week
    when 5
      ref_date += value.month
    when 6
      ref_date += value.year
    else
      puts "Error:"+params[:alert][:unit].to_s
    end
    
    puts "hhhhhhhhhhhhey"+ref_date.to_s

    ref_date
  end

  def destroy
    @alert = Alert.find(params[:id])
    issue_id=@alert.issue_id
    @issue = Issue.find(issue_id)
    @alert.destroy

    render_update
  end
end
