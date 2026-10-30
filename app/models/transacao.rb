class Transacao < ApplicationRecord
  belongs_to :aluno, class_name: "User", inverse_of: :transacoes
  belongs_to :restaurante, optional: true
  belongs_to :refeicao, optional: true

  validates :data_hora, :tipo, presence: true
  validates :valor, presence: true, numericality: true
end
