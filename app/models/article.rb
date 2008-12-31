class Article < ActiveRecord::Base
  belongs_to :article_category
  #alptodo: need to sequence by position within category - the following does not accomplish this currently...
  acts_as_list :scope => :article_category
  #alptodo: make sure article category exists before saving
end
