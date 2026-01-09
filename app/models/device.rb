class Device < ApplicationRecord
  has_many :readings, dependent: :delete_all
end