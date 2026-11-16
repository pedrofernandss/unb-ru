class Restaurante < ApplicationRecord
  # Opcional porque a unidade é cadastrada pelo administrador só com nome e pisos.
  belongs_to :campus, optional: true

  has_many :catracas, -> { order(:piso, :numero) }, dependent: :restrict_with_error
  has_many :refeicoes, dependent: :destroy
  has_many :transacoes, dependent: :nullify
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :destroy

  validates :nome, presence: true
  validates :numero_de_pisos, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :campus_id, uniqueness: true, allow_nil: true
  validate :nome_unico
  validate :pisos_comportam_catracas, if: :numero_de_pisos_changed?

  def catracas_do_piso(piso)
    catracas.select { |catraca| catraca.piso == piso }
  end

  private

  # Erro em :base para a mensagem não sair prefixada com "Nome da Unidade".
  def nome_unico
    return if nome.blank?

    errors.add(:base, :nome_em_uso) if Restaurante.where.not(id: id).exists?(nome: nome)
  end

  def pisos_comportam_catracas
    return unless numero_de_pisos.is_a?(Integer) && persisted?

    piso_mais_alto = catracas.maximum(:piso)
    return if piso_mais_alto.nil? || numero_de_pisos >= piso_mais_alto

    errors.add(:numero_de_pisos, :abaixo_das_catracas, piso: piso_mais_alto)
  end
end
