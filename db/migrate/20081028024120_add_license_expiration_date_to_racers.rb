class AddLicenseExpirationDateToRacers < ActiveRecord::Migration
  def self.up
    add_column :racers, :license_expiration_date, :date
  end

  def self.down
    remove_column :racers, :license_expiration_date
  end
end
