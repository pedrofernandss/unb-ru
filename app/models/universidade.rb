class Universidade < ApplicationRecord
  has_many :campi, dependent: :destroy

  validates :nome, presence: true, uniqueness: true
end
