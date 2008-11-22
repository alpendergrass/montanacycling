require 'fileutils'

# Year-long competition that derive there standings from other Events:
# BAR, Ironman, WSBA Rider Rankings, Oregon Cup.
class Competition < Event
  include FileUtils

  # TODO Validate dates
  # TODO Use class methods to set things like friendly_name
  # TODO Just how much memory is this thing hanging on to?
  attr_accessor :point_schedule
  
  after_create  :create_standings
  # return true from before_save callback or Competition won't save
  before_save   {|competition| competition.notification = false; true}
  after_save    :expire_cache
  
  def self.find_for_year(year = Date.today.year)
    self.find_by_date(Date.new(year, 1, 1))
  end
  
  # Update results based on source event results.
  # (Calculate clashes with internal Rails method)
  # Destroys existing Competition for the year first.
  # TODO store intermeditate results in database?
  def Competition.recalculate(year = Date.today.year)
    # TODO: Use FKs in database to cascade delete
    # TODO Use Hashs or class instead of iterating through Arrays!
    benchmark(name, Logger::INFO, false) {
      transaction do
        # TODO move to superclass
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)
        competition = self.find_or_create_by_date(date)
        raise(ActiveRecord::ActiveRecordError, competition.errors.full_messages) unless competition.errors.empty?
        competition.destroy_standings
        competition.create_standings
        # Could bulk load all Standings and Races at this point, but hardly seems to matter
        competition.calculate_members_only_places
        competition.recalculate
      end
    }
    # Don't return the entire populated instance!
    true
  end
  
  def initialize(attributes = nil)
    super
    if self.date.month != 1 or self.date.day != 1
      self.date = Date.new(Date.today.year)    
    end
  end

  def friendly_name
    'Competition'
  end
  
  # Same as +date+. Should always be January 1st
  def start_date
    date
  end
  
  # Last day of year for +date+
  def end_date
    Date.new(date.year, 12, 31)
  end
  
  # Assert start and end dates are first and last days of the year
  def valid_dates
    if !start_date or start_date.month != 1 or start_date.day != 1
      errors.add("start_date", "Start date must be January 1st")
    end
    if !end_date or end_date.month != 12 or end_date.day != 31
      errors.add("end_date", "End date must be December 31st")
    end
  end

  # TODO Is this really good Rails API usage?
  def destroy_standings
    for s in standings(true)
      Standings.delete(s.id)
    end
  end
  
  def name
    self[:name] ||= "#{date.year} #{friendly_name}"
  end
  
  def create_standings
    new_standings = standings.create
    category = Category.find_or_create_by_name(friendly_name)
    new_standings.races.create(:category => category)
    new_standings
  end

  def calculate_members_only_places
    if place_members_only?
      for race in Race.find_by_sql([%Q{
        select races.id 
        from races
        left outer join standings on standings.id = races.standings_id
        left outer join events on events.id = standings.event_id
        where events.type <> ? and events.date between ? and ?},
        self.class.name.demodulize, start_date, end_date])
        
        race = Race.find(:first,
                         :include => [{:results => :racer}, {:standings => :event}],
                         :conditions => ['races.id = ?', race.id])
        race.calculate_members_only_places!
      end
    end
  end
  
  def recalculate
    for individual_standings in standings(true)
      for race in individual_standings.races
        results = source_results_with_benchmark(race)
        create_competition_results_for(results, race)
        after_create_competition_results_for(race)
        race.place_results_by_points(break_ties?)
      end
    end
    save!
  end
  
  def point_schedule
    @point_schedule = @point_schedule || []
  end
  
  # source_results must be in racer, place ascending order
  def source_results(race)
    []
  end
  
  # Array of ids (integers)
  # +race+ category, +race+ category's siblings, and any competition categories
  def category_ids_for(race)
    ids = [race.category_id]
    ids = ids + race.category.descendants.map {|category| category.id}
    ids.join(', ')
  end
  
  # If same ride places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      racer = source_result.racer
      points = points_for(source_result)
      if points > 0.0 && (!members_only? || member?(racer, source_result.date))
 
        if first_result_for_racer(source_result, competition_result)
          # Intentionally not using results association create method. No need to hang on to all competition results.
          # In fact, this could cause serious memory issues with the Ironman
          competition_result = Result.create!(
             :racer => racer, 
             :team => (racer ? racer.team : nil),
             :race => race)
        end
 
        Competition.benchmark('competition_result.scores.create_if_best_result_for_race') {
          competition_result.scores.create_if_best_result_for_race(
            :source_result => source_result, 
            :competition_result => competition_result, 
            :points => points
          )
        }
      end
      
      # Aggressive memory management. If competition has a race with many results, 
      # the results array can become a large, uneeded, structure
      results[index] = nil
      GC.start if index > 0 && index % 1000 == 0
    end
  end
  
  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
  end
  
  def break_ties?
    true
  end
  
  # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
  def place_members_only?
    false
  end
  
  # Only members can score points?
  def members_only?
    true 
  end
  
  def member?(racer_or_team, date)
    racer_or_team && racer_or_team.member_in_year?(date)
  end
  
  def first_result_for_racer(source_result, competition_result)
    competition_result.nil? || source_result.racer != competition_result.racer
  end
  
  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    # TODO Consider indexing place
    # TODO Consider caching/precalculating team size
    team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
    if place_members_only?
      points = point_schedule[source_result.members_only_place.to_i].to_f
    else
      points = point_schedule[source_result.place.to_i].to_f
    end
    if points
      points / team_size.to_f
    else
      0
    end
  end

  def expire_cache
  end

  def to_s
    "<self.class #{id} #{name} #{start_date} #{end_date}>"
  end
  
  protected
  
  def source_results_with_benchmark(race)
    results = []
    Competition.benchmark("#{self.class.name} source_results", Logger::DEBUG, false) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end
end
