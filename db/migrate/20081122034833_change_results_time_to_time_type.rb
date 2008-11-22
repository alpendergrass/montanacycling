class ChangeResultsTimeToTimeType < ActiveRecord::Migration
  def self.up
    change_column :results, :time, :time
    change_column :results, :time_bonus_penalty, :time
    change_column :results, :time_gap_to_leader, :time
    change_column :results, :time_gap_to_previous, :time
    change_column :results, :time_gap_to_winner, :time
    change_column :results, :time_total, :time
  end

  def self.down
    change_column :results, :time, :float
    change_column :results, :time_bonus_penalty, :float
    change_column :results, :time_gap_to_leader, :float
    change_column :results, :time_gap_to_previous, :float
    change_column :results, :time_gap_to_winner, :float
    change_column :results, :time_total, :float
  end
end
