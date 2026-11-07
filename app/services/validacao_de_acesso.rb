# Único fluxo de débito/registro/comando para modo comum e FastPass.
# Ponto de integração com #6/#7: não existe outro mecanismo publicado na base auditada.
class ValidacaoDeAcesso
  class EventoIncompativel < StandardError; end

  def self.processar!(catraca:, matricula:, chave:, modo: "FastPass", agora: Time.current, dispositivo: Catracas.dispositivo)
    raise ArgumentError, "Modo inválido" unless %w[FastPass Comum].include?(modo)
    raise ArgumentError, "Chave obrigatória" if chave.blank?

    agora = agora.in_time_zone
    evento = ProcessamentoAcesso.find_by(chave: chave)
    unless evento
      ProcessamentoAcesso.transaction do
        # Bloqueio do aluno serializa os débitos; o índice único protege a repetição.
        aluno = User.aluno.find_by(matricula: matricula)
        aluno&.lock!
        catraca.lock!
        turno = TipoRefeicao.all.detect do |tipo|
          agora.between?(RegraFastpass.horario_na_data(agora.to_date, tipo.hora_inicio),
                         RegraFastpass.horario_na_data(agora.to_date, tipo.hora_fim))
        end
        motivo = if !catraca.online?
          "Catraca offline"
        elsif !dispositivo.disponivel?
          "Dispositivo de catraca indisponível"
        elsif !aluno
          "Aluno não encontrado"
        elsif !turno
          "Fora do turno de refeição"
        elsif modo == "FastPass"
          RegraFastpass.motivo_bloqueio(aluno: aluno, catraca: catraca, turno: turno, agora: agora)
        end
        motivo ||= "Saldo insuficiente" if aluno && aluno.saldo < TarifaRefeicao.valor
        liberado = motivo.nil?
        evento = ProcessamentoAcesso.create!(chave: chave, catraca: catraca, aluno: aluno,
          matricula: matricula, modo: modo, data_hora: agora, liberado: liberado, motivo: motivo || "Validação concluída")
        if aluno
          evento.update!(historico_catraca: catraca.historicos_catraca.create!(aluno: aluno, data_hora: agora))
        end
        if liberado
          aluno.update!(saldo: aluno.saldo - TarifaRefeicao.valor)
          refeicao = catraca.restaurante.refeicoes.find_by(data: agora.to_date, tipo_refeicao: turno)
          evento.update!(transacao: aluno.transacoes.create!(catraca: catraca, restaurante: catraca.restaurante,
            refeicao: refeicao, data_hora: agora, tipo: turno.nome, metodo: modo, valor: -TarifaRefeicao.valor))
        end
      end
    end

    unless evento.catraca_id == catraca.id && evento.matricula == matricula && evento.modo == modo
      raise EventoIncompativel, "Evento já utilizado em outra leitura"
    end
    evento.enviar_comando!(dispositivo: dispositivo)
    evento
  rescue ActiveRecord::RecordNotUnique
    # Outra requisição concluiu esta chave. Reaproveita a decisão já persistida.
    retry
  end
end
