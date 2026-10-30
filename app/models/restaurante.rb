class Restaurante < ApplicationRecord
  belongs_to :campus

  has_many :catracas, dependent: :destroy
  has_many :refeicoes, dependent: :destroy
  has_many :transacoes, dependent: :nullify
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :destroy

  validates :nome, presence: true
  validates :campus_id, uniqueness: true
end
