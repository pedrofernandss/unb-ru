class Catraca < ApplicationRecord
  belongs_to :restaurante
  belongs_to :funcionario, class_name: "User", optional: true, inverse_of: :catraca

  # Sem dependent: os acessos são o registro de auditoria do relatório global (#9) e
  # impedem a remoção da catraca (ver impedir_remocao_com_acessos).
  has_many :historicos_catraca, class_name: "HistoricoCatraca"
  has_many :processamentos_acesso, class_name: "ProcessamentoAcesso"
  has_many :transacoes, dependent: :nullify

  validates :numero, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :piso, presence: true, numericality: { only_integer: true }
  validates :funcionario_id, uniqueness: true, allow_nil: true
  validate :numero_unico_no_restaurante
  validate :piso_existe_no_restaurante

  # prepend: roda antes do nullify das transações, para não alterar nada quando a remoção é recusada.
  before_destroy :impedir_remocao_com_acessos, prepend: true

  def identificacao = format("Catraca %02d", numero)

  private

  def impedir_remocao_com_acessos
    return unless historicos_catraca.exists? || processamentos_acesso.exists?

    errors.add(:base, :possui_acessos)
    throw :abort
  end

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
