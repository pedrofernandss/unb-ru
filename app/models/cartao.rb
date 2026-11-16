class Cartao < ApplicationRecord
  belongs_to :aluno, class_name: "User", inverse_of: :cartoes

  validates :numero, presence: true, uniqueness: { scope: :aluno_id }
  validates :bandeira, :nome, :validade, :codigo_verificacao, presence: true
  validates :saldo, numericality: { greater_than_or_equal_to: 0 }
end
