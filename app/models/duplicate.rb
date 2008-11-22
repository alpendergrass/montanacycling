# TODO: +new_record+ and +attributes+ are somewhat redundant
class Duplicate < ActiveRecord::Base
  serialize :new_attributes
  validates_presence_of :new_attributes

  has_and_belongs_to_many :racers
  
  def racer
    @racer ||= Racer.new(self.new_attributes)
  end
end