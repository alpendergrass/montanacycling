class AddParentIdToArticleCategory < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :parent_id, :integer, :default => 0
  end

  def self.down
    remove_column :article_categories, :parent_id
  end
end
