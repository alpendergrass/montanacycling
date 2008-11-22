class MailingList < ActiveRecord::Base

  has_many :posts
  
  # Range of first Post date and last post date
  # Return nil..nil if no Posts
  # Cache SQL results
  # FIXME Hack: Just finds first and last post in ENTIRE table. Incorrect, 
  # but 50+ times faster
  def dates
    if @dates.nil?
      first_post = connection.select_value("select min(date) from posts")
      if first_post
        last_post = connection.select_value("select max(date) from posts")
        @dates = Date.parse(first_post)..Date.parse(last_post)
      end
    end
    return @dates
  end
  
  def reload
    super
    @dates = nil
  end

  def to_s
    "<#{self.class} #{id} #{name} #{friendly_name}>"
  end

end