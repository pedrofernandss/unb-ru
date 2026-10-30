# Representa Aluno e Funcionário do MER (e o administrador), diferenciados por perfil.
class User < ApplicationRecord
  # Matrícula SIGAA (ex: 2023123456) ou SIAPE (ex: 1984201): apenas dígitos.
  FORMATO_MATRICULA = /\A\d{7,12}\z/
  TAMANHO_MINIMO_SENHA = 8

  has_secure_password

  enum :perfil, { aluno: "aluno", funcionario: "funcionario", administrador: "administrador" }, default: :aluno

  # Relacionamentos de Aluno
  has_many :cartoes, foreign_key: :aluno_id, inverse_of: :aluno, dependent: :destroy
  has_many :transacoes, foreign_key: :aluno_id, inverse_of: :aluno, dependent: :destroy
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", foreign_key: :aluno_id,
                                 inverse_of: :aluno, dependent: :destroy
  has_many :historicos_catraca, class_name: "HistoricoCatraca", foreign_key: :aluno_id,
                                inverse_of: :aluno, dependent: :destroy

  # Relacionamento de Funcionário
  has_one :catraca, foreign_key: :funcionario_id, inverse_of: :funcionario, dependent: :nullify

  normalizes :nome, with: ->(nome) { nome.squish }
  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true, length: { maximum: 120 }
  validates :matricula, presence: true,
                        uniqueness: true,
                        format: { with: FORMATO_MATRICULA, message: :formato_matricula, allow_blank: true }
  validates :password, length: { minimum: TAMANHO_MINIMO_SENHA }, allow_nil: true
  validates :saldo, numericality: { greater_than_or_equal_to: 0 }
end
