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
      aplicar_resultado(provedor.cobrar(chave: chave, valor: valor, metodo: metodo)) if pendente?
    end
    self
  end

  private

  # Sem resposta do provedor (:pendente), a recarga continua aguardando nova confirmação.
  def aplicar_resultado(resultado)
    case resultado
    when :aprovado then creditar!
    when :recusado then update!(status: :recusada)
    end
  end

  def creditar!
    aluno.with_lock do
      aluno.update!(saldo: aluno.saldo + valor)
      update!(status: :aprovada, transacao: registrar_credito)
    end
  end

  # Crédito que aparece no extrato do aluno.
  def registrar_credito
    aluno.transacoes.create!(data_hora: Time.current, tipo: "Recarga de Saldo", valor: valor, metodo: metodo)
  end

  def quantidade_valida
    unless quantidade_before_type_cast.to_s.match?(/\A\d+\z/) && quantidade.between?(1, 50)
      errors.add(:base, "Informe uma quantidade entre 1 e 50 refeições")
    end
  end

  def calcular_valor
    self.valor = quantidade.to_i * TarifaRefeicao.referencia
  end
end
