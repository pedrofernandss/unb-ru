class HistoricoCatraca < ApplicationRecord
  self.table_name = "historicos_catraca"

  belongs_to :catraca
  belongs_to :aluno, class_name: "User", inverse_of: :historicos_catraca

  validates :data_hora, presence: true
end
