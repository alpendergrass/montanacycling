class AddCategoryClassToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :category_class, :string, :limit => 16
  end

  def self.down
    remove_column :results, :category_class
  end
end
