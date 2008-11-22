class AddGenderToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :gender, :string, :limit => 8
  end

  def self.down
    remove_column :results, :gender
  end
end
