class ProcessamentoAcesso < ApplicationRecord
  self.table_name = "processamentos_acesso"
  belongs_to :catraca
  belongs_to :aluno, class_name: "User", optional: true
  belongs_to :historico_catraca, optional: true
  belongs_to :transacao, optional: true
  validates :chave, :matricula, :data_hora, :motivo, presence: true
  validates :modo, inclusion: { in: %w[FastPass Comum] }

  def comando = liberado? ? :liberar : :bloquear
  def resultado = liberado? && comando_enviado_em? ? "ACESSO LIBERADO" : "ACESSO BLOQUEADO"

  # Caixa de saída persistente: falha do dispositivo pode ser tentada novamente
  # sem novo débito. O adaptador deve deduplicar a mesma chave no dispositivo.
  def enviar_comando!(dispositivo: Catracas.dispositivo)
    with_lock do
      return if comando_enviado_em?
      return unless dispositivo.disponivel? && catraca.reload.online?

      if dispositivo.enviar(catraca: catraca, comando: comando, evento_id: chave)
        update!(comando_enviado_em: Time.current)
      end
    end
  end
end
