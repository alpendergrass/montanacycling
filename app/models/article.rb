class Article < ActiveRecord::Base
  belongs_to :article_category
  acts_as_list :scope => :article_category
  #alptodo: make sure article category exists before saving
end
