require File.dirname(__FILE__) + '/../test_helper'

class SingleDayEventTest < ActiveSupport::TestCase
  
  def test_find_all_by_year
    begin
      show_only_association_sanctioned_races_on_calendar = ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = true
      events = SingleDayEvent.find_all_by_year(2004)
      assert_equal(4, events.size, "test_find_all_by_year for 2004 events only found: #{events.join(', ')}")

      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = false
      events = SingleDayEvent.find_all_by_year(2004)
      assert_equal(5, events.size, "test_find_all_by_year for 2004 events only found: #{events.join(', ')}")
    ensure
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = show_only_association_sanctioned_races_on_calendar
    end
  end

  def test_new
    event = SingleDayEvent.new
    assert_equal(0, event.standings.size, "New event should have no standings")
  end

  def test_create
    event = SingleDayEvent.create
    assert_equal('-------------', event.first_aid_provider, "New event first aid provider")

    event = SingleDayEvent.create(:name => 'Copperopolis')
    assert_equal('-------------', event.first_aid_provider, "New event first aid provider")
  end
  
  def test_full_name
    kings_valley = events(:kings_valley_2004)
    assert_equal('Kings Valley Road Race', kings_valley.full_name, 'Event with no parent full_name')

    stage = events(:mt_hood_1)
    assert_equal('Mt. Hood Classic Mount Hood Day 1', stage.full_name, 'stage full_name')
    
    stage_race = events(:mt_hood)
    stage.name = stage_race.name
    assert_equal('Mt. Hood Classic', stage.full_name, 'stage full_name')

    stage.name = stage_race.name + ' Stage One'
    assert_equal('Mt. Hood Classic Stage One', stage.full_name, 'stage full_name')
  end
  
  def test_missing_parent
    assert(events(:lost_series_child).missing_parent?, 'missing_parent?')
    assert_equal(events(:series_parent), events(:lost_series_child).missing_parent, 'missing_parent')
    assert(!(events(:mt_hood_1).missing_parent?), 'missing_parent?')
    assert_nil(events(:mt_hood_1).missing_parent, 'missing_parent')
  end
  
  def test_velodrome
    event = events(:kings_valley_2004)
    event.velodrome = velodromes(:alpenrose)
    event.save!
    assert_equal(velodromes(:alpenrose), event.velodrome(true), "Should associate velodrome with event")
  end
end