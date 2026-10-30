class InscricaoFastpass < ApplicationRecord
  self.table_name = "inscricoes_fastpass"

  belongs_to :aluno, class_name: "User", inverse_of: :inscricoes_fastpass
  belongs_to :restaurante
  belongs_to :refeicao

  validates :data, presence: true
  validates :aluno_id, uniqueness: { scope: :refeicao_id }
end
