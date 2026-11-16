# Café da manhã, almoço ou jantar, com o horário em que é servido e a tarifa cobrada.
class TipoRefeicao < ApplicationRecord
  self.table_name = "tipos_refeicao"

  NUMERO_INTEIRO = /\A-?\d+\z/

  has_many :refeicoes, dependent: :restrict_with_error
  has_many :time_frames, -> { order(:inicio) }, dependent: :destroy
  # Inscrições que somem junto quando as janelas do turno são apagadas.
  has_many :inscricoes_fastpass, through: :time_frames

  validates :nome, presence: true, uniqueness: true
  validates :hora_inicio, :hora_fim, presence: true, unless: :horario_invalido?
  validates :tarifa, numericality: { greater_than: 0 }
  validate :horario_reconhecido
  validate :fim_depois_do_inicio, :sem_sobreposicao, if: -> { hora_inicio && hora_fim }

  # Só rodam ao configurar os time-frames, para não bloquear a edição de horários.
  validate :granularidade_valida, :tolerancia_valida, on: :configuracao_time_frames

  # Janelas geradas para o horário antigo ficariam fora do turno: o admin gera de novo.
  after_update :descartar_time_frames, if: -> { saved_change_to_hora_inicio? || saved_change_to_hora_fim? }

  # Ordena pela hora local. O ORDER BY do banco usa os horários em UTC, e um turno
  # depois das 22:00 passa da meia-noite e vai para o começo da lista (#39).
  def self.em_ordem = all.sort_by { |turno| turno.hora_inicio.strftime("%H:%M") }

  def self.vigente_em(agora = Time.current)
    momento = agora.in_time_zone
    data = momento.to_date
    all.detect do |tipo|
      inicio = horario_na_data(data, tipo.hora_inicio)
      fim = horario_na_data(data, tipo.hora_fim)
      momento.between?(inicio, fim)
    end
  end

  # As colunas de horário guardam só a hora (com a data 2000-01-01); aqui ela vai para a data pedida.
  def self.horario_na_data(data, horario)
    Time.zone.local(data.year, data.month, data.day, horario.hour, horario.min, horario.sec)
  end

  def hora_inicio_formatada
    formatar_horario(hora_inicio)
  end

  def hora_fim_formatada
    formatar_horario(hora_fim)
  end

  # Grava a configuração e, se a granularidade mudou, recria as janelas do turno.
  # Retorna false se for inválida. O save! valida uma vez só e, se falhar, desfaz a
  # transação e deixa os erros em errors.
  def configurar_time_frames(granularidade:, tolerancia:)
    self.granularidade_minutos = granularidade
    self.tolerancia_minutos = tolerancia
    # Com a mesma granularidade as janelas atuais continuam valendo: só a tolerância muda.
    recriar = granularidade_minutos_changed? || time_frames.empty?

    transaction do
      save!(context: :configuracao_time_frames)
      recriar_time_frames if recriar
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    # Só o erro do próprio turno tem mensagem para o admin. Se uma janela falhar,
    # o erro sobe em vez de virar um "não foi possível" sem explicação.
    raise unless e.record == self

    false
  end

  def duracao_em_minutos
    ((hora_fim - hora_inicio) / 60).to_i
  end

  private

  def formatar_horario(horario)
    return horario.strftime("%H:%M") if horario.respond_to?(:strftime)

    horario.to_s.slice(0, 5)
  end

  def recriar_time_frames
    time_frames.destroy_all
    quantidade = duracao_em_minutos / granularidade_minutos
    quantidade.times do |i|
      time_frames.create!(inicio: hora_inicio + (i * granularidade_minutos).minutes,
                          fim: hora_inicio + ((i + 1) * granularidade_minutos).minutes)
    end
  end

  # Sem janelas, a configuração antiga deixa de valer e o admin configura de novo.
  def descartar_time_frames
    time_frames.destroy_all
    update_columns(granularidade_minutos: nil, tolerancia_minutos: nil)
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
  # A comparação é feita em Ruby pela hora local, e não pelo banco: em UTC os turnos
  # depois das 22:00 passam da meia-noite e a comparação falha (#39).
  # O return if errors.any? pula a busca quando o horário já é inválido. Por isso
  # esta validação depende da ordem: precisa ser declarada depois das de horário.
  def sem_sobreposicao
    return if errors.any?

    inicio, fim = hora_inicio.strftime("%H:%M"), hora_fim.strftime("%H:%M")
    outro = TipoRefeicao.where.not(id: id).em_ordem.detect do |turno|
      turno.hora_inicio.strftime("%H:%M") < fim && turno.hora_fim.strftime("%H:%M") > inicio
    end
    errors.add(:base, :sobreposicao, turno: nome, outro: outro.nome) if outro
  end
end
