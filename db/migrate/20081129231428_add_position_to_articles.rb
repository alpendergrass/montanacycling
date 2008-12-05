class AddPositionToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :position, :integer, :default => 0
  end

  def self.down
    remove_column :articles, :position
  end
end
