class AddClubNameAndNcaaClubNameToRacers < ActiveRecord::Migration
  def self.up
    add_column :racers, :club_name, :string
    add_column :racers, :ncca_club_name, :string
  end

  def self.down
    remove_column :racers, :club_name
    remove_column :racers, :ncca_club_name
  end
end
