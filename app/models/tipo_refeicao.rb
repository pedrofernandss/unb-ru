# Café da manhã, almoço ou jantar, com o horário em que é servido.
class TipoRefeicao < ApplicationRecord
  self.table_name = "tipos_refeicao"

  has_many :refeicoes, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
  validates :hora_inicio, :hora_fim, presence: true, unless: :horario_invalido?
  validate :horario_reconhecido
  validate :fim_depois_do_inicio, :sem_sobreposicao, if: -> { hora_inicio && hora_fim }

  private

  # O Rails converte "25:00" em nil; o texto digitado continua em *_before_type_cast.
  def horario_invalido?
    %i[hora_inicio hora_fim].any? do |campo|
      self[campo].nil? && read_attribute_before_type_cast(campo).present?
    end
  end

  def horario_reconhecido
    errors.add(:base, :horario_invalido) if horario_invalido?
  end

  def fim_depois_do_inicio
    errors.add(:base, :fim_antes_do_inicio) if hora_fim <= hora_inicio
  end

  # Dois intervalos se sobrepõem quando um começa antes de o outro terminar e vice-versa.
  def sem_sobreposicao
    return if errors.any?

    TipoRefeicao.where.not(id: id).each do |outro|
      if hora_inicio < outro.hora_fim && hora_fim > outro.hora_inicio
        errors.add(:base, :sobreposicao, turno: nome, outro: outro.nome)
      end
    end
  end
end
