class Catraca < ApplicationRecord
  belongs_to :restaurante
  belongs_to :funcionario, class_name: "User", optional: true, inverse_of: :catraca

  has_many :historicos_catraca, class_name: "HistoricoCatraca", dependent: :destroy
  has_many :transacoes, dependent: :nullify

  validates :numero, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :piso, presence: true, numericality: { only_integer: true }
  validates :funcionario_id, uniqueness: true, allow_nil: true
  validate :numero_unico_no_restaurante
  validate :piso_existe_no_restaurante

  def identificacao = format("Catraca %02d", numero)

  private

  def numero_unico_no_restaurante
    return unless restaurante_id && numero

    duplicada = Catraca.where(restaurante_id: restaurante_id, numero: numero).where.not(id: id).exists?
    errors.add(:base, :numero_em_uso) if duplicada
  end

  def piso_existe_no_restaurante
    return unless restaurante && piso.is_a?(Integer)
    return if piso.between?(1, restaurante.numero_de_pisos)

    errors.add(:piso, :fora_do_restaurante, maximo: restaurante.numero_de_pisos)
  end
end
