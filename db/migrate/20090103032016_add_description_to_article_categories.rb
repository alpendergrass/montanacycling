class AddDescriptionToArticleCategories < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :description, :string
  end

  def self.down
    remove_column :article_categories, :description
  end
end
