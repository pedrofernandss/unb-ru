# Café da manhã, almoço ou jantar, com o horário em que é servido e a tarifa cobrada.
class TipoRefeicao < ApplicationRecord
  self.table_name = "tipos_refeicao"

  has_many :refeicoes, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
  validates :hora_inicio, :hora_fim, presence: true
  validates :tarifa, numericality: { greater_than: 0 }
end
