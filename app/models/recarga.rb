class Recarga < ApplicationRecord
  belongs_to :aluno, class_name: "User", inverse_of: :recargas
  belongs_to :transacao, optional: true

  enum :status, { pendente: "pendente", aprovada: "aprovada", recusada: "recusada" }, default: :pendente
  validates :chave, presence: true, uniqueness: true
  validates :metodo, inclusion: { in: %w[PIX Cartão] }
  validate :quantidade_valida
  before_validation :calcular_valor, on: :create

  # A confirmação é idempotente. Apenas o adaptador do servidor determina o resultado.
  def confirmar!(provedor: Pagamentos.provedor)
    with_lock do
      return self unless pendente?

      resultado = provedor.cobrar(chave: chave, valor: valor, metodo: metodo)
      if resultado == :aprovado
        aluno.with_lock do
          aluno.update!(saldo: aluno.saldo + valor)
          credito = aluno.transacoes.create!(data_hora: Time.current, tipo: "Recarga de Saldo",
                                             valor: valor, metodo: metodo)
          update!(status: :aprovada, transacao: credito)
        end
      elsif resultado == :recusado
        update!(status: :recusada)
      end
    end
    self
  end

  private

  def quantidade_valida
    unless quantidade_before_type_cast.to_s.match?(/\A\d+\z/) && quantidade.between?(1, 50)
      errors.add(:base, "Informe uma quantidade entre 1 e 50 refeições")
    end
  end

  def calcular_valor
    self.valor = quantidade.to_i * TarifaRefeicao.referencia
  end
end
