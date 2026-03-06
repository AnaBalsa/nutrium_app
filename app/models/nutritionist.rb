class Nutritionist < ApplicationRecord
    has_many :services, dependent: :destroy
    has_many :appointment_requests, dependent: :destroy

    validates :name, presence: true
end
