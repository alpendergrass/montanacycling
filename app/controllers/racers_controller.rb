class RacersController < ApplicationController
  def index
    @racers = []
    @name = params['name'] || ''
    @name.strip!
    if @name.blank?
      @racers = Racer.paginate :page => params[:page], :order => 'last_name asc, first_name asc'
    else
      @racers = Racer.find_all_by_name_like(@name)
      @racers = @racers.paginate(:page => params[:page])
      @name = ''
    end

    @discipline_names = Discipline.find_all_names
    #alptodo: we need to cache discipline_names
  end

end
