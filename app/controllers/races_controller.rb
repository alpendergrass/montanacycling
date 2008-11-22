class RacesController < ApplicationController

  # Show Races for a Category
  # === Params
  # * id: Category ID
  # === Assigns
  # * races
  # * category
  def category
    @category = Category.find(params[:id])
  end

end
