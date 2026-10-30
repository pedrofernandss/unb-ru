# Uma refeição servida em um restaurante em determinado dia (ex: almoço de 30/10).
class Refeicao < ApplicationRecord
  belongs_to :restaurante
  belongs_to :tipo_refeicao

  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :destroy
  has_many :transacoes, dependent: :nullify

  validates :data, presence: true
  validates :tipo_refeicao_id, uniqueness: { scope: [ :restaurante_id, :data ] }
end
