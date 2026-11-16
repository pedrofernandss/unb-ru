# Único fluxo de débito/registro/comando para modo comum e FastPass.
# Ponto de integração com #6/#7: não existe outro mecanismo publicado na base auditada.
class ValidacaoDeAcesso
  class EventoIncompativel < StandardError; end

  def self.processar!(catraca:, matricula:, chave:, modo: "FastPass", agora: Time.current, dispositivo: Catracas.dispositivo)
    raise ArgumentError, "Modo inválido" unless %w[FastPass Comum].include?(modo)
    raise ArgumentError, "Chave obrigatória" if chave.blank?

    agora = agora.in_time_zone
    codigo = matricula.to_s.strip
    matricula_esperada = nil
    evento = ProcessamentoAcesso.find_by(chave: chave)
    unless evento
      ProcessamentoAcesso.transaction do
        # Lock pessimista no aluno e na catraca evita corrida entre duas leituras simultâneas
        # (duplo débito de saldo ou dupla liberação no mesmo ponto de acesso).
        aluno = User.aluno.find_by(matricula: codigo) || User.aluno.find_by(qr_code: codigo)
        aluno&.lock!
        catraca.lock!
        matricula_esperada = aluno ? aluno.matricula : codigo
        turno = TipoRefeicao.vigente_em(agora)
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
        # Cada turno tem sua própria tarifa; o débito é sempre o do turno da leitura.
        tarifa = TarifaRefeicao.do_turno(turno)
        motivo ||= "Saldo insuficiente" if aluno && aluno.saldo < tarifa
        liberado = motivo.nil?
        evento = ProcessamentoAcesso.create!(chave: chave, catraca: catraca, aluno: aluno,
          matricula: matricula_esperada, modo: modo, data_hora: agora, liberado: liberado, motivo: motivo || "Validação concluída")
        if aluno
          # Projeção de leitura de #7/#9, gravada na mesma transação da decisão:
          # o histórico local e o relatório global leem estes campos direto,
          # sem passar por ProcessamentoAcesso.
          evento.update!(historico_catraca: catraca.historicos_catraca.create!(aluno: aluno, data_hora: agora,
            modo_validacao: modo, status: liberado ? "Liberado" : "Bloqueado",
            tarifa: liberado ? tarifa : 0, motivo: evento.motivo))
        end
        if liberado
          aluno.update!(saldo: aluno.saldo - tarifa)
          refeicao = catraca.restaurante.refeicoes.find_by(data: agora.to_date, tipo_refeicao: turno)
          evento.update!(transacao: aluno.transacoes.create!(catraca: catraca, restaurante: catraca.restaurante,
            refeicao: refeicao, data_hora: agora, tipo: turno.nome, metodo: modo, valor: -tarifa))
        end
      end
    end

    matricula_esperada ||= (User.aluno.find_by(matricula: codigo) || User.aluno.find_by(qr_code: codigo))&.matricula || codigo

    unless evento.catraca_id == catraca.id && evento.matricula == matricula_esperada && evento.modo == modo
      raise EventoIncompativel, "Evento já utilizado em outra leitura"
    end
    evento.enviar_comando!(dispositivo: dispositivo)
    evento
  rescue ActiveRecord::RecordNotUnique
    # Outra requisição concorrente gravou a mesma chave de idempotência antes desta transação:
    # reexecuta o fluxo para carregar o evento persistido e verificar compatibilidade.
    retry
  end
end
