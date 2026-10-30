class Campus < ApplicationRecord
  belongs_to :universidade
  has_one :restaurante, dependent: :destroy

  validates :nome, presence: true, uniqueness: { scope: :universidade_id }
end
