# Janela de chegada do FastPass dentro de um turno (ex.: 11:15 - 11:30).
class TimeFrame < ApplicationRecord
  belongs_to :tipo_refeicao

  # Janela apagada (ex.: o admin mudou o horário do turno) leva as inscrições junto.
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :destroy

  validates :inicio, :fim, presence: true
end
