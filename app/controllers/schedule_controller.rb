# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController

    session :off
    caches_page :index, :list

    # Default calendar format
    # === Params
    # * year: default to current year
    # * discipline
    # === Assigns
    # * year
    # * schedule: instance of year's Schedule::Schedule
    def index
       collect_schedule_data
    end

    # List of events -- one line per event
    # === Params
    # * year: default to current year
    # === Assigns
    # * year
    # * schedule: instance of year's Schedule::Schedule
    def list
       collect_schedule_data
    end
   
  private
    
    def collect_schedule_data
        @year = params["year"].to_i
        @year = Date.today.year if @year == 0
        @discipline = Discipline[params["discipline"]]
        @discipline_names = Discipline.find_all_names
        #RAILS_DEFAULT_LOGGER.debug("def index @discipline =  #{@discipline}")
        events = SingleDayEvent.find_all_by_year(@year, @discipline)
        @schedule = Schedule::Schedule.new(@year, events)
    end
end