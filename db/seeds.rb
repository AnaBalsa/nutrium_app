puts "Cleaning database..."

AppointmentRequest.destroy_all
Service.destroy_all
Nutritionist.destroy_all

puts "Creating Nutricionists..."

nutritionists = [
  "Ana Silva",
  "Miguel Santos",
  "Carla Ferreira",
  "João Costa",
  "Mariana Lopes"
]

cities = {
  "Braga" => { lat: 41.5454, lng: -8.4265 },
  "Porto" => { lat: 41.1579, lng: -8.6291 },
  "Lisboa" => { lat: 38.7223, lng: -9.1393 },
  "Coimbra" => { lat: 40.2033, lng: -8.4103 },
  "Faro" => { lat: 37.0194, lng: -7.9304 }
}

nutritionists.each do |name|
  nutritionist = Nutritionist.create!(name: name)

  # creates at least one nutri from braga
  braga_coords = cities["Braga"]

  Service.create!(
    nutritionist: nutritionist,
    name: "Initial Appointment",
    price: rand(4000..9000),
    currency: "EUR",
    duration_minutes: [30, 45, 60].sample,
    location_name: "Braga",
    location_lat: braga_coords[:lat],
    location_lng: braga_coords[:lng]
  )

  4.times do |i|
    city_name, coords = cities.to_a.sample

    Service.create!(
      nutritionist: nutritionist,
      name: ["Initial Appointment", "Personalized Meal Plan", "Follow-up", "Sports Nutrition"].sample,
      price: rand(4000..9000),
      currency: "EUR",
      duration_minutes: [30, 45, 60].sample,
      location_name: city_name,
      location_lat: coords[:lat],
      location_lng: coords[:lng]
    )
  end
end

puts "Done!"