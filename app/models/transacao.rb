class Transacao < ApplicationRecord
  belongs_to :aluno, class_name: "User", inverse_of: :transacoes
  belongs_to :restaurante, optional: true
  belongs_to :refeicao, optional: true
  belongs_to :catraca, optional: true

  validates :data_hora, :tipo, presence: true
  validates :valor, presence: true, numericality: true

  scope :debitos, -> { where(valor: ...0) }
  scope :creditos, -> { where(arel_table[:valor].gt(0)) }
  scope :no_periodo, ->(inicio, fim) { where(data_hora: inicio.beginning_of_day..fim.end_of_day) }
  scope :recentes, -> { order(data_hora: :desc, id: :desc) }

  def debito? = valor.negative?
  def recarga? = valor.positive?

  # Onde a transação aconteceu, como aparece no extrato: "RU Darcy Ribeiro - Piso 2".
  def local
    if catraca
      "#{catraca.restaurante.nome} - Piso #{catraca.piso}"
    elsif restaurante
      restaurante.nome
    else
      "Recarga de saldo"
    end
  end

  def detalhe_local
    if catraca
      format("Catraca %02d", catraca.numero)
    elsif recarga?
      "Crédito em carteira"
    end
  end
end
