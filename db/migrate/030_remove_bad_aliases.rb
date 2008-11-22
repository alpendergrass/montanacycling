class RemoveBadAliases < ActiveRecord::Migration
  def self.up
    Alias.transaction do
      bad_aliases = Alias.connection.select_values('select aliases.id from aliases, teams where aliases.name = teams.name')
      for bad_alias in bad_aliases
        Alias.destroy(bad_alias) if Alias.exists?(bad_alias)
      end

      bad_aliases = Alias.connection.select_values("select aliases.id from aliases, racers where trim(concat(first_name, ' ', last_name)) = aliases.name")
      for bad_alias in bad_aliases
        Alias.destroy(bad_alias) if Alias.exists?(bad_alias)
      end
    end
  end

  def self.down
  end
end
