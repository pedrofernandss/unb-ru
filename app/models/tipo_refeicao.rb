# Café da manhã, almoço ou jantar, com o horário em que é servido.
class TipoRefeicao < ApplicationRecord
  self.table_name = "tipos_refeicao"

  NUMERO_INTEIRO = /\A-?\d+\z/

  has_many :refeicoes, dependent: :restrict_with_error
  has_many :time_frames, -> { order(:inicio) }, dependent: :destroy

  validates :nome, presence: true, uniqueness: true
  validates :hora_inicio, :hora_fim, presence: true, unless: :horario_invalido?
  validate :horario_reconhecido
  validate :fim_depois_do_inicio, :sem_sobreposicao, if: -> { hora_inicio && hora_fim }

  # Só rodam ao configurar os time-frames, para não bloquear a edição de horários.
  validate :granularidade_valida, :tolerancia_valida, on: :configuracao_time_frames

  # Janelas geradas para o horário antigo ficariam fora do turno: o admin gera de novo.
  after_update :descartar_time_frames, if: -> { saved_change_to_hora_inicio? || saved_change_to_hora_fim? }

  # Grava a configuração e recria as janelas do turno. Retorna false se for inválida.
  # O save! valida uma vez só e, se falhar, desfaz a transação e deixa os erros em errors.
  def configurar_time_frames(granularidade:, tolerancia:)
    self.granularidade_minutos = granularidade
    self.tolerancia_minutos = tolerancia

    transaction do
      save!(context: :configuracao_time_frames)
      time_frames.destroy_all
      quantidade = duracao_em_minutos / granularidade_minutos
      quantidade.times do |i|
        time_frames.create!(inicio: hora_inicio + (i * granularidade_minutos).minutes,
                            fim: hora_inicio + ((i + 1) * granularidade_minutos).minutes)
      end
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def duracao_em_minutos
    ((hora_fim - hora_inicio) / 60).to_i
  end

  private

  def descartar_time_frames
    time_frames.destroy_all
  end

  def granularidade_valida
    if !granularidade_minutos_before_type_cast.to_s.match?(NUMERO_INTEIRO)
      errors.add(:base, :granularidade_nao_numerica)
    elsif granularidade_minutos <= 0
      errors.add(:base, :granularidade_nao_positiva)
    elsif hora_inicio && hora_fim && duracao_em_minutos % granularidade_minutos != 0
      errors.add(:base, :granularidade_nao_divide, duracao: duracao_em_minutos)
    end
  end

  def tolerancia_valida
    unless tolerancia_minutos_before_type_cast.to_s.match?(NUMERO_INTEIRO) && tolerancia_minutos >= 0
      errors.add(:base, :tolerancia_invalida)
    end
  end

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
  # A comparação é feita pelo banco, que devolve só o primeiro turno em conflito.
  def sem_sobreposicao
    return if errors.any?

    outro = TipoRefeicao.where.not(id: id)
                        .where("hora_inicio < ? AND hora_fim > ?", hora_fim, hora_inicio)
                        .order(:hora_inicio).first
    errors.add(:base, :sobreposicao, turno: nome, outro: outro.nome) if outro
  end
end
