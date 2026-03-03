class Service < ApplicationRecord
    belongs_to :nutritionist

    validates :name, :duration_minutes, :location_name, presence: true
    validates :duration_minutes, numericality: { greater_than: 0 }
    validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
