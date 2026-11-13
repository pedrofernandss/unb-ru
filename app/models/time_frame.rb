# Janela de chegada do FastPass dentro de um turno (ex.: 11:15 - 11:30).
class TimeFrame < ApplicationRecord
  belongs_to :tipo_refeicao

  validates :inicio, :fim, presence: true
end
