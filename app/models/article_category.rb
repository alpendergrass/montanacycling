class ArticleCategory < ActiveRecord::Base
  has_many :articles
  acts_as_tree :order=>"name"
  #alptodo: need to sequence by position within parent 
#  acts_as_list  :scope => :parent_id
  #alptodo: make sure no articles in category before delete
end
