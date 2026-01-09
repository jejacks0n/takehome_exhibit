class Reading < ApplicationRecord
  belongs_to :device

  validates :count, :timestamp, presence: true
end