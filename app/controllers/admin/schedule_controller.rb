# View schedule with links to admin Event pages
class Admin::ScheduleController < ApplicationController

  layout 'admin/application'
  before_filter :login_required

  # schedule calendar  with links to admin Event pages
  # === Params
  # * year: (optional) defaults to current year
  # === Assigns
  # * schedule
  # * year
  def index
    @year = params["year"].to_i
    @year = Date.today.year if @year == 0
    events = SingleDayEvent.find(:all, :conditions => ["date between ? and ?", "#{@year}-01-01", "#{@year}-12-31"])
    events = events + MultiDayEvent.find(:all, :conditions => ["date between ? and ?", "#{@year}-01-01", "#{@year}-12-31"])
    @schedule = Schedule::Schedule.new(@year, events)
  end
  
  # Upload new Excel Schedule
  # See Schedule::Schedule.import for details
  # Redirects to schedule index if succesful
  # === Params
  # * schedule_file
  # === Flash
  # * notice
  # * warn
  def upload
    begin
      uploaded_file = params[:schedule_file]
      path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
      File.open(path, File::CREAT|File::WRONLY) do |f|
        f.print(uploaded_file.read)
      end

      date = Schedule::Schedule.import(path, params[:delete_all_future_events])
      expire_cache
      flash[:notice] = "Uploaded schedule from #{uploaded_file.original_filename}"
      redirect_path = {
        :controller => "/admin/schedule", 
        :action => :index, 
        :year => date.year
      }
#    rescue  Exception => error
#      redirect_path = {
#        :controller => "/admin/schedule"
#      }
#      flash[:warn] = "Could not import schedule: #{error}"
    end
    
    redirect_to(redirect_path)
  end
end
