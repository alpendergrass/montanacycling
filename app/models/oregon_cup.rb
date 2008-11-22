# Year-long best rider competition for senior men and women
class OregonCup < Competition

  # 2006 races: 19, 80, 81, 259, 265, 381, 411
  # TODO Initialize OregonCup with "today" attribute
  # TODO Break ties according to rules on website
  has_many :events

  def friendly_name
    'Oregon Cup'
  end
  
  def point_schedule
    [0, 100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10]
  end

  # source_results must be in racer-order
  def source_results(race)
    return [] if events(true).empty?
    
    event_ids = events.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')    
    
    results = Result.find_by_sql(
      %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN standings ON races.standings_id = standings.id 
          LEFT OUTER JOIN events ON standings.event_id = events.id 
            WHERE races.category_id is not null 
              and ((standings.bar_points > 0 and !(standings.name like '%Overall%'))
                   or (standings.bar_points = 0 and standings.name like '%Combined%'))
              and place between 1 and 20
              and categories.id in (#{category_ids_for(race)})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race)}))
              and events.id in (#{event_ids})
         order by racer_id
       }
    )
    remove_separate_women_1_2_results(results)
    results
  end
  
  # Unfortunate workaround for Rehearsal Road Race and Tabor
  def remove_separate_women_1_2_results(results)
    results.delete_if do |result|
      result.race.name == "Women 1/2" && result.race.standings.name = "Rehearsal Road Race"
      result.race.name == "Senior Women" && result.race.standings.name = "Mount Tabor Circuit Race"
    end
  end
  
  def create_standings
    root_standings = standings.create(:event => self)

    category = Category.find_or_create_by_name('Senior Men')
    root_standings.races.create(:category => category)

    category = Category.find_or_create_by_name('Senior Women')
    root_standings.races.create(:category => category)
  end
  
  def latest_event_with_standings
    for event in events.sort
      for standings in event.standings
        for race in standings.races
          if !race.results.empty?
            return event
          end
        end
      end
    end
    nil
  end
  
  def more_events?(today = Date.today)
    !self.next_event(today).nil?
  end
  
  # FIXME: Needs to sort by date?
  def next_event(today = Date.today)
    for event in events.sort
      if event.date > today
        return event
      end
    end
    nil
  end
end