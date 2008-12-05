class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.string :heading
      t.string :description
      t.boolean :display
      t.text :body

      t.references :article_category
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
