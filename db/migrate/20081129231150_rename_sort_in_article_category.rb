class RenameSortInArticleCategory < ActiveRecord::Migration
  def self.up
    rename_column :article_categories, :sort, :position
  end

  def self.down
    rename_column :article_categories, :position, :sort
  end
end
