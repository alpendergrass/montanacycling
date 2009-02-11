class AddUsacEventNumberToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :usac_event_number, :string, :limit => 8
  end

  def self.down
    remove_column :events, :usac_event_number
  end
end
