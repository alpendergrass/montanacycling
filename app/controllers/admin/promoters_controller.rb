# Manage race promoters
#
# Promoter information shows up on the schedules
class Admin::PromotersController < ApplicationController

  layout 'admin/application'
  before_filter :login_required
  cache_sweeper :schedule_sweeper, :only => [:update]

  # List all Promoters
  # === Assigns
  # * promoters
  def index
    @promoters = Promoter.find(:all).sort_by{|p| p.name_or_contact_info}
  end

  # === Params
  # * id
  # === Assigns
  # * promoter
  def edit
    @promoter = Promoter.find(params['id'])
    remember_event
  end
  
  def new
    @promoter = Promoter.new
    remember_event
    render(:action => :edit)
  end

  def create
    begin
      remember_event
      @promoter = Promoter.create(params['promoter'])
      if @promoter.errors.empty?
        if @event
          redirect_to(edit_admin_promoter_path(@promoter, :event_id => @event.id))
        else
          redirect_to(edit_admin_promoter_path(@promoter))
        end
      else
        render(:action => :edit)
      end
    rescue Exception => e
      logger.error(e)
      flash['warn'] = e.message
      render(:action => :edit)
    end
  end
  
  # Update new (no :id param) or existing Promoter
  # No duplicate names
  def update
    begin
      remember_event
      @promoter = Promoter.update(params['id'], params['promoter'])
      if @promoter.errors.empty?
        if @event
          redirect_to(edit_admin_promoter_path(@promoter, :event_id => @event.id))
        else
          redirect_to(edit_admin_promoter_path(@promoter))
        end
      else
        render(:action => :edit)
      end
    rescue Exception => e
      logger.error(e)
      flash['warn'] = e.message
      render(:action => :edit)
    end
  end
  
  private
  
  def remember_event
    unless params['event_id'].blank?
      @event = Event.find(params['event_id'])
    end
  end
end
