class NutritionistsController < ApplicationController
  def index
    @nutritionists = Nutritionist.order(:name)
  end

  def pending_requests
    @nutritionist = Nutritionist.find(params[:id])
  end
end
