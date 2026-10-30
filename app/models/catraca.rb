class Catraca < ApplicationRecord
  belongs_to :restaurante
  belongs_to :funcionario, class_name: "User", optional: true, inverse_of: :catraca

  has_many :historicos_catraca, class_name: "HistoricoCatraca", dependent: :destroy

  validates :numero, presence: true, uniqueness: { scope: :restaurante_id }
  validates :piso, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :funcionario_id, uniqueness: true, allow_nil: true
end
