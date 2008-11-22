# Alternate name for a Racer or Team. Example: Erik Tonkin might have aliases of 'Eric Tonkin,' and 'E. Tonkin'
# Must belong to either a Racer or Team, but not both. Used by Result when importing results from Excel.
class Alias < ActiveRecord::Base
  belongs_to :racer
  belongs_to :team
  
  validates_presence_of :name
  validate :racer_or_team
  validate :cannot_shadow_racer
  validate :cannot_shadow_team
  
  def Alias.find_all_racers_by_name(name)
    aliases = Alias.find(
      :all, 
      :conditions => ['name = ? and racer_id is not null', name],
      :include => :racer
    )
    aliases.collect do |racer_alias|
      racer_alias.racer
    end
  end
  
  def Alias.find_all_teams_by_name(name)
    aliases = Alias.find(
      :all, 
      :conditions => ['aliases.name = ? and team_id is not null', name],
      :include => :team
    )
    aliases.collect do |team_alias|
      team_alias.team
    end
  end
  
  def racer_or_team
    unless (racer and !team) or (!racer and team)
      errors.add('racer or team', 'Must have exactly one racer or team')
    end
  end
  
  def cannot_shadow_racer
    if Racer.count(:conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name]) > 0
      errors.add('name', "Racer named '#{name}' already exists")
    end
  end
  
  def cannot_shadow_team
    if Team.count(:name, :conditions => ['name = ?', name]) > 0
      errors.add('name', "Team named '#{name}' already exists")
    end
  end

  def to_s
    "<#{self.class.name} #{self[:id]} #{self[:name]} #{self[:racer_id]} #{self[:team_id]}>"
  end
end
