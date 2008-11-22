# Homepage
class HomeController < ApplicationController
  caches_page :index
        
  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  # * recent_results: Events with Results within last two weeks
  def index
    #@upcoming_events = UpcomingEvents.find_all
    #alphere to fix the above I had to create records in the disciplines table for each discipline hard coded in def disciplines_for(discipline)
    @upcoming_events = UpcomingEvents.find_all(:weeks => 12)
    
    # cutoff = Date.today - 14
    cutoff = '2008-01-01'
    @recent_results = Standings.find(
      :all,
      :include => :event,
      #alphere :conditions => ['events.date > ? and events.sanctioned_by = ? and standings.type is null', cutoff, ASSOCIATION.short_name],
      :conditions => ['events.date > ? and standings.type is null', cutoff],
      :order => 'events.date desc'
    )
  end
  
  def auction
    @bid = Bid.highest
    render(:partial => 'auction')
  end
  
  def bid
    @highest_bid = Bid.highest
    @bid = Bid.new
  end
  
  def send_bid
    @bid = Bid.create(params[:bid])
    if @bid.errors.empty?
      begin
        BidMailer.create_created(@bid)
      rescue Exception => e
        logger.error("Could not send bid email notification: #{e}")
      end
      redirect_to :action => 'confirm_bid'
    else
      @highest_bid = Bid.highest
      render(:action => 'bid')
    end
  end
end
