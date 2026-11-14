class HistoricoCatraca < ApplicationRecord
  self.table_name = "historicos_catraca"

  belongs_to :catraca
  belongs_to :aluno, class_name: "User", inverse_of: :historicos_catraca
  has_one :processamento_acesso, dependent: :nullify

  validates :data_hora, presence: true
  validates :modo_validacao, inclusion: { in: %w[FastPass Comum] }
  validates :status, inclusion: { in: %w[Liberado Bloqueado] }
  validates :tarifa, numericality: { greater_than_or_equal_to: 0 }
end
