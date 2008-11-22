class AddShortDescAndStageNameToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :short_description, :string
    add_column :events, :stage_name, :string
  end

  def self.down
    remove_column :events, :short_description
    remove_column :events, :stage_name
  end
end
