class ChangeResultsAgeToString < ActiveRecord::Migration
  def self.up
    change_column :results, :age, :string, :limit => 16
  end

  def self.down
    change_column :results, :age, :integer
  end
end
