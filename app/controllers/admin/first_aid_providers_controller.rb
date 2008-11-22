class Admin::FirstAidProvidersController < ApplicationController
  
  before_filter :login_required
  helper :table
  in_place_edit_for :event, :first_aid_provider
  layout "admin/application"

  def index
    @year = Date.today.year
    @past_events = params[:past_events] || false
    if @past_events
      conditions = ['date >= ?', Date.today.beginning_of_year]
    else
      conditions = ['date >= CURDATE()']
    end
    @events = SingleDayEvent.find(:all, :conditions => conditions)
    
    respond_to do |format|
      format.html
      format.text { email }
    end
  end

  def email
    rows = @events.collect do |event|
      [event.first_aid_provider, event.date.strftime("%a %m/%d") , event.name, event.city_state]
    end
    grid = Grid.new(rows)
    grid.truncate_rows
    grid.calculate_padding
    
    headers['Content-Type'] = 'text/plain'

    render :text => grid.to_s(false)
  end
end