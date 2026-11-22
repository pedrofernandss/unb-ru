class ProcessamentoAcesso < ApplicationRecord
  self.table_name = "processamentos_acesso"
  belongs_to :catraca
  belongs_to :aluno, class_name: "User", optional: true
  belongs_to :historico_catraca, optional: true
  belongs_to :transacao, optional: true
  validates :chave, :matricula, :data_hora, :motivo, presence: true
  validates :modo, inclusion: { in: %w[FastPass Comum] }

  def comando = liberado? ? :liberar : :bloquear

  # Liberado com débito feito, mas sem confirmação da catraca. Estado próprio:
  # exibir "ACESSO BLOQUEADO" aqui levava o operador a ler o QR de novo, o que
  # abre outra chave e debita a refeição mais uma vez. A entrega é retomada
  # reenviando a MESMA chave, que não gera novo débito.
  def entrega_pendente? = liberado? && !comando_enviado_em?

  RESULTADOS = { liberado: "ACESSO LIBERADO", pendente: "COMANDO PENDENTE",
                 bloqueado: "ACESSO BLOQUEADO" }.freeze

  def estado
    return :pendente if entrega_pendente?

    liberado? ? :liberado : :bloqueado
  end

  def resultado = RESULTADOS.fetch(estado)

  # Caixa de saída persistente: falha do dispositivo pode ser tentada novamente
  # sem novo débito. O adaptador deve deduplicar a mesma chave no dispositivo.
  def enviar_comando!(dispositivo: Catracas.dispositivo)
    with_lock do
      entregar_comando(dispositivo) if pode_enviar?(dispositivo)
    end
  end

  private

  # Envia uma única vez, e só com dispositivo e catraca disponíveis no momento do envio.
  def pode_enviar?(dispositivo)
    !comando_enviado_em? && dispositivo.disponivel? && catraca.reload.online?
  end

  def entregar_comando(dispositivo)
    update!(comando_enviado_em: Time.current) if dispositivo.enviar(catraca: catraca, comando: comando, evento_id: chave)
  end
end
