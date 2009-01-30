module Schedule
  # Single year's event schedule. Hierarchical model or Arrays: Schedule --> Month --> Week --> Day --> SingleDayEvent
  class Schedule

    # FIXME Remove dependency. Is it here because we need a helper?
    include ActionView
    
    COLUMN_MAP = {
      'Race'                                   => 'name',
      'Event'                                  => 'name',
      'StageName'                              => 'stage_name',
      'Stage'                                  => 'stage_name',
      'CityState'                              => 'city',
      'Promoter'                               => 'promoter_name',
      'PromoterPhone'                          => 'promoter_phone',
      'PromoterEmail'                          => 'promoter_email',
      'SponsoringTeam'                         => 'team_id',
      'Team'                                   => 'team_id',
      'Club'                                   => 'team_id',
      'SanctionedBy'                           => 'sanctioned_by',
      'ShortDescription'                       => 'short_description',
      'Website'                                => 'flyer',
      'FlyerApproved'                          => 'flyer_approved'
    }

    # 0-based array of Months
    attr_reader :months, :year

    # Import Schedule from Excel +filename+.
    #
    # *Warning:* Deletes all events after the schedule's first event date - optional
    #
    # Import implemented in several methods. See source code.
    # === Returns
    # * date of first event


    
    def Schedule.import(filename, delete_all_future = 0)
      # alptodo not deleting future can result in dups and generates MultiDayEvents (?)
      date = nil
      Event.transaction do
        file             = read_file(filename)
        date             = read_date(file)
                           delete_all_future_events(date) if delete_all_future.to_i > 0
        events           = parse_events(file)
        multi_day_events = find_multi_day_events(events)
                           save(events, multi_day_events)
      end
      date
    end
    
    def Schedule.read_date(file)
      row_hash = file.rows.first.to_hash
      date = Date.parse(row_hash[:date])
      logger.debug("Schedule Import starting at #{date}")
      date
    end
    
    # Events with results _will not_ be destroyed
    def Schedule.delete_all_future_events(date)
      logger.debug("Delete all events after #{date}")
      Event.destroy_all(["date >= ?", date])
    end
    
    # Create GridFile
    def Schedule.read_file(filename)
      logger.debug("Read #{filename}")

      options = {
#        :delimiter => ',',
#        :quoted => true,
        :header_row => true,
        :column_map => COLUMN_MAP
      }

      GridFile.new(File.new(filename), options)
    end

    # Read GridFile +file+, split city and state, read and create promoter
    def Schedule.parse_events(file)
      events = []
      for row in file.rows
        row_hash = row.to_hash

        if has_event?(row_hash)
          split_city_state(row_hash)
          event = Schedule.parse(row_hash)
          if event != nil
            # Save to persist new promoters (if there is one)
            # to prevent duplicate promoters in memory
            # TODO Check for dupe promoters at save time instead
            event.find_associated_records
            if event.promoter
              event.promoter.save! 
            end
            events << event
          end
        end
      end
      return events
    end

    def Schedule.has_event?(row_hash)
      name = row_hash[:name]
      date = row_hash[:date]
      return (!name.blank? and !date.blank?)
    end

    # Split location on comma
    def Schedule.split_city_state(row_hash)
      city = row_hash[:city]
      state = row_hash[:state]
      if !city.nil? and (state == "" or state.nil?)
        #alp remove embedded quotes stuck on by Excel when saving xls as tab-delimited text file 
        #city.gsub!(/"/, "")
        city, state = city.split(",")
        city.strip! unless city.nil?
        row_hash[:city] = city 
        state.strip! unless state.nil?
        row_hash["state"] = state 
        one = 1
      end
    end

    # Read GridFile Row and create SingleDayEvent
    def Schedule.parse(row_hash)
      logger.debug(row_hash.inspect) if logger.debug?
      event = nil
      if !(row_hash[:date].blank? and row_hash[:name].blank?)
        begin
          #alphere this returns invalid date for e.g. 2/19/2008 
          #row_hash[:date] = Date.strptime(row_hash[:date], "%Y-%m-%d")
        rescue
          logger.warn($!)
          row_hash[:date] = nil
        end
        if row_hash[:discipline]
          discipline = Discipline.find_via_alias(row_hash[:discipline])
          if discipline != nil
            row_hash[:discipline] = discipline.name
          else
            row_hash[:discipline] = ASSOCIATION.default_discipline
          end
        end

        if !row_hash.has_key?(:sanctioned_by)
            row_hash[:sanctioned_by] = DEFAULT_SANCTIONING_ORGANIZATION
        end
 
        if row_hash[:team_id]
          row_hash[:team_id] = Team.find_or_create_by_name(row_hash[:team_id]).id
        end
 
        event = SingleDayEvent.new(row_hash)
        if logger.debug? then logger.debug("Add #{event.name} to schedule") end
      end
      return event
    end

    # Try and create parent MultiDayEvents from imported SingleDayEvents
    def Schedule.find_multi_day_events(events)
      logger.debug("Find multi-day events")

      # Hash of Arrays keyed by event name
      events_by_name = Hash.new
      for event in events
        logger.debug("Find multi-day events #{event.name}")
        event_array = events_by_name[event.name] || Array.new
        event_array << event
        events_by_name[event.name] = event_array if event_array.size == 1
      end
  
      multi_day_events = []
      for key_value in events_by_name
        name, event_array = key_value
        if event_array.size > 1
          logger.debug("Create multi-day event #{name}")
          multi_day_events << MultiDayEvent.create_from_events(event_array)
        end
      end
  
      return multi_day_events
    end

    def Schedule.add_one_day_events_to_parents(events, multi_day_events)
      #alphere: I think this method is not used...
      for event in events
        parent = multi_day_events[event.name]
        if !parent.nil?
          parent.events << event
        end
      end
    end

    def Schedule.save(events, multi_day_events)
      for event in events
        logger.debug("Save #{event.name}")
        event.save!
      end
      for event in multi_day_events
        logger.debug("Save #{event.name}")
        event.save!
      end
    end
    
    def Schedule.logger
      RAILS_DEFAULT_LOGGER
    end

    def initialize(year, events)
      @year = year.to_i
      @months = []
      for month in 1..12
        @months << Month.new(year, month)
      end
      for event in events
        month = @months[event.date.month - 1]
        if month.nil?
          raise(IndexError, "Could not find month for #{event.date.month} in year #{year}")
        end
        month.add(event)
      end
    end
  end

  # Hash that keeps a count for each key
  class HashBag < Hash

    def initialize
      @counts = {}
      super
    end

    def []=(key, value)
      count = count(key)
      count = count + 1
      @counts[key] = count
      super
    end

    def count(key)
      count = @counts[key]

      if count != nil
        count    
      else
        0
      end
    end
  end
end
