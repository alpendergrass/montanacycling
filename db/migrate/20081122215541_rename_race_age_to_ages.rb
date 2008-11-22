class RenameRaceAgeToAges < ActiveRecord::Migration
  def self.up
    rename_column :results, :age, :ages
  end

  def self.down
    rename_column :results, :ages, :age
  end
end
