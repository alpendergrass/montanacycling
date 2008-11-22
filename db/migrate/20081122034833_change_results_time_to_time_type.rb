class ChangeResultsTimeToTimeType < ActiveRecord::Migration
  def self.up
    change_column :results, :time, :time
    change_column :results, :time_total, :time
  end

  def self.down
    change_column :results, :time, :float
    change_column :results, :time_total, :float
  end
end
