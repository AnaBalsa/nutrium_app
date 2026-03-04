class SearchController < ApplicationController
  CITY_COORDS = {
    "Braga" => { lat: 41.5454, lng: -8.4265 },
    "Porto" => { lat: 41.1579, lng: -8.6291 },
    "Lisboa" => { lat: 38.7223, lng: -9.1393 },
    "Coimbra" => { lat: 40.2033, lng: -8.4103 },
    "Faro" => { lat: 37.0194, lng: -7.9304 }
  }.freeze

  DEFAULT_CITY = "Braga"

  def index
    @query = params[:search_term].to_s.strip.first(100)
    @location = normalize_city(params[:location])

    coords = CITY_COORDS[@location]
    @target_lat = coords[:lat]
    @target_lng = coords[:lng]

    services = Service.joins(:nutritionist).includes(:nutritionist)
    services = apply_text_search(services, @query)

    services = services.select(
      "services.*,
      ((services.location_lat - #{@target_lat})*(services.location_lat - #{@target_lat}) + (services.location_lng - #{@target_lng})*(services.location_lng - #{@target_lng})) AS distance_sq"
    ).order(Arel.sql("distance_sq ASC"))

    @services = services.limit(50)
  end

  private

  def normalize_city(raw_location)
    city = raw_location.to_s.strip
    return DEFAULT_CITY if city.blank?
    CITY_COORDS.key?(city) ? city : DEFAULT_CITY
  end

  def apply_text_search(services, query)
    return services if query.blank?

    safe = ActiveRecord::Base.sanitize_sql_like(query)
    pattern = "\\m#{safe}\\M"
    services.where(
      "services.name ~* :q OR nutritionists.name ~* :q",
      q: pattern
    )
  end
end
