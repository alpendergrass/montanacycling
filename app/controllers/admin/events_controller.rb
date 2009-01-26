# Show Schedule, add and edit Events, show Results for Events
class Admin::EventsController < ApplicationController
  
  before_filter :login_required
  layout 'admin/application'
  cache_sweeper :home_sweeper, :results_sweeper, :schedule_sweeper, :only => [:create, :update, :destroy_event, :destroy_standings, :upload]
  
  def index
    @year = Date.today.year
    @past_events = params[:past_events] || false
    @events = SingleDayEvent.find(:all)
  end

  # Show results for Event
  # === Params
  # * id: SingleDayEvent id
  # * standings_id: Standings id (optional
  # * race_id: Race id (optional
  # === Assigns
  # * event
  # * standings
  # * race
  # * disciplines: List of all Disciplines + blank
  def show
    @event = Event.find(params[:id])
    if params[:race_id]
      @race = Race.find(params[:race_id])
    elsif params[:standings_id]
      @standings = Standings.find(params[:standings_id])
    end

    @disciplines = [''] + Discipline.find(:all).collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
    
    unless params['promoter_id'].blank?
      @event.promoter = Promoter.find(params['promoter_id'])
    end
  end
  
  # Show page to create new Event
  # === Params
  # * year: optional
  # === Assigns
  # * event: Unsaved SingleDayEvent
  def new
    if params[:year].blank?
      date = Date.today
    else
      year = params[:year]
      date = Date.new(year.to_i)
    end
    @event = SingleDayEvent.new(:date => date, :discipline => ASSOCIATION.default_discipline)
    association_number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name)
    @event.number_issuer_id = association_number_issuer.id
  end
  
  # Create new SingleDayEvent
  # === Params
  # * event: Attributes Hash for new event
  # === Assigns
  # * event: Unsaved SingleDayEvent
  # === Flash
  # * warn
  def create
    event_type = params[:event][:type]
    raise "Unknown event type: #{event_type}" unless ['SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
    @event = eval(event_type).new(params[:event])
    if @event.save
      expire_cache
      flash[:notice] = "Created #{@event.name}"
      redirect_to(:controller => :schedule, :action => :index)
    else
      flash[:warn] = @event.errors.full_messages
      render(:action => :new)
    end
  end
  
  # Create new MultiDayEvent from 'prototype' SingleDayEvent
  # === Params
  # * id: SingleDayEvent
  # === Flash
  # * warn
  def create_from_events
    single_day_event = Event.find(params[:id])
    new_parent = MultiDayEvent.create_from_events(single_day_event.multi_day_event_children_with_no_parent)
    expire_cache
    redirect_to(:action => :show, :id => new_parent.to_param)
  end
  
  # Update existing Event
  # === Params
  # * id
  # * event: Attributes Hash
  # === Assigns
  # * event: Unsaved Event
  # === Flash
  # * warn
  def update
    expire_cache
    if params[:race_id]
      @race = Race.update(params[:race_id], params[:race])
      if @race.errors.empty?
        redirect_to(:action => :show, :id => params[:id], :standings_id => params[:standings_id], :race_id => params[:race_id])
      else
        render(:action => :show)
      end
    elsif params[:standings_id]
      @standings = Standings.update(params[:standings_id], params[:standings])
      if @standings.errors.empty?
        redirect_to(:action => :show, :standings_id => params[:standings_id], :id => params[:id])
      else
        render(:action => :show)
      end
    else
      begin
        @event = Event.find(params[:id])
        # TODO consolidate code
        event_params = params[:event].clone
        @event = Event.update(params[:id], event_params)
        event_type = params[:event][:type]
        if !event_type.blank? && event_type != @event.type
          raise "Unknown event type: #{event_type}" unless ['SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
          @event.events.clear if event_type == 'SingleDayEvent' && @event.is_a?(MultiDayEvent)
          @event.save!
          Event.connection.execute("update events set type = '#{event_type}' where id = #{@event.id}")
          @event = Event.find(@event.id)
        end
      rescue Exception => e
        stack_trace = e.backtrace.join("\n")
        logger.error("#{e}\n#{stack_trace}")
        flash[:warn] = e
        return render(:action => :show)
      end
      
      if @event.errors.empty?
        flash[:notice] = "Updated #{@event.name}"
#        redirect_to(:action => :show, :id => params[:id])
        redirect_to(:controller => :schedule, :action => :index)
      else
        render(:action => :show)
      end
    end
  end

  # Upload results from csv or Excel spreadsheet (broken). 
  # Expects column headers in first row
  # === Params
  # * results_file
  # * id: Event ID
  # === Flash
  # * warn: List unrecognized columns
  # * notice
  def upload
    uploaded_file = params[:results_file]
    path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
    File.open(path, File::CREAT|File::WRONLY) do |f|
      f.print(uploaded_file.read)
    end

    temp_file = File.new(path)
    event_id = params[:id]
    event = Event.find(event_id)
    results_file = ResultsFile.new(temp_file, event)
    begin
      standings = results_file.import
      expire_cache
      flash[:notice] = "Uploaded results for #{uploaded_file.original_filename}"
      unless results_file.invalid_columns.empty?
        flash[:warn] = "Unrecognized columns in uploaded file (you can probably ignore): #{results_file.invalid_columns.join(', ')}."
      end
      redirect_path = {
        :controller => "/admin/events", 
        :action => :show, 
        :standings_id => standings.to_param,
        :id => event.to_param
      }
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      redirect_path = {
        :controller => "/admin/events",
        :action => :show,
        :id => event.to_param,

      }
      flash[:warn] = "Could not upload results: #{error}"
    end
    
    redirect_to(redirect_path)
  end
  
  # Permanently destroy Event
  # === Params
  # * id
  # === Assigns
  # * event: if Event could not be deleted
  # === Flash
  # * notice
  def destroy_event
    event = Event.find(params[:id])
    begin
      if event.has_children?
        flash[:notice] = "Event has child event(s). You must delete any children before deleting this event."
        redirect_to(:action => :show, :id => params[:id])
      else
        event.destroy
        expire_cache
        flash[:notice] = "Deleted #{event.name}"
        redirect_to(:controller => "/admin/schedule", :action => "index", :year => event.date.year)
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      flash[:notice] =  "Could not delete #{event.name}"
      redirect_to(:action => :show, :id => params[:id])
    end
  end
  
  # Permanently destroy Standings and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy_standings
    standings = Standings.find(params[:id])
    begin
      standings.destroy
      expire_cache
      flash[:notice] = "Deleted #{standings.name}"
      render :update do |page|
        page.visual_effect(:puff, "standings_#{standings.id}_row", :duration => 2)
        page.redirect_to(
          :controller => "/admin/events", 
          :action => :show, 
          :id => standings.event.to_param
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{standings.name}"
      render :update do |page|
        page.replace_html("message_#{standings.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  # Permanently destroy race and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy_race
    race = Race.find(params[:id])
    begin
      race.destroy
      render :update do |page|
        page.visual_effect(:puff, "race_#{race.id}_row", :duration => 2)
        flash[:notice] = "Deleted #{race.name}"
        page.redirect_to(
          :controller => "/admin/events", 
          :action => :show, 
          :id => race.standings.event.to_param
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{race.name}"
      render :update do |page|
        page.replace_html("message_#{race.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  # Insert new Result and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def insert_result
    begin
      result = Result.find(params[:id])
      new_place = result.place
      results = result.race.results.sort
      start_index = results.index(result)
      for index in start_index...(results.size)
        if results[index].place.to_i > 0
          results[index].place = results[index].place.to_i + 1
          results[index].save!
        end
      end
      result.race.results.create(:place => new_place)
      render :update do |page|
        page.redirect_to(:action => :show, :id => result.race.standings.event.id, :standings_id => result.race.standings.id, :race_id => result.race.id)
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not insert result"
      render :update do |page|
        page.replace_html("message_#{result.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  # Permanently destroy Results and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy_result
    result = Result.find(params[:id])
    begin
      result.destroy
      render :update do |page|
        page.visual_effect(:puff, "result_#{result.id}_row", :duration => 2)
        page.replace_html(
          'message', 
          "#{image_tag('icons/confirmed.gif', :height => 11, :width => 11, :id => 'confirmed') } Deleted #{result.place} #{result.name}"
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{result.name}"
      render :update do |page|
        page.replace_html("message_#{result.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end

  # Inline update of Race BAR points
  # === Params
  # * id
  # * bar_points
  def update_bar_points
    bar_points = params[:bar_points]
    race = Race.update(params[:id], :bar_points => bar_points)
    render(:partial => 'bar_points', :locals => {:race => race, :bar_points => bar_points})
  end
  
  # AJAX method: update promoter's contact information when different promoter selected
  # === Params
  # * promoter_id
  # * id: Event ID
  def promoter_changed
    promoter_id = params['promoter_id']
    if promoter_id.blank?
      render :update do |page|
      end
    else
      promoter = Promoter.find(promoter_id)
      render :update do |page|
        page.replace_html("promoter_email", promoter.email)
        page.replace_html("promoter_phone", promoter.phone)
        page.replace_html("edit_promoter_link", 
          link_to(
              'Edit', 
              :controller => 'promoters', 
              :action => 'show', 
              :id => promoter.id,
              :event_id => params['id'])
          )
        page.visual_effect(:appear, 'promoter_email', :duration => 0.5)
        page.visual_effect(:appear, 'promoter_phone', :duration => 0.5)
        page.visual_effect(:appear, 'edit_promoter_link', :duration => 0.5)
      end
    end
  end

  def set_parent
    child = Event.find(params[:child_id])
    parent = Event.find(params[:parent_id])
    child.parent = parent
    child.save!
    redirect_to(:action => :show, :id => child)
  end
  
  # :nodoc
  def update_promoter(promoter, params)
    if promoter and (params[:name] != promoter.name or params[:email] != promoter.email or params[:phone] != promoter.phone)
      promoter.name = params[:name]
      promoter.email = params[:email]
      promoter.phone = params[:phone]
    end
  end
  
  def add_children
    parent = Event.find(params[:parent_id])
    parent.missing_children.each do |child|
      child.parent = parent
      child.save!
    end
    redirect_to(:action => :show, :id => parent.id)
  end
end
