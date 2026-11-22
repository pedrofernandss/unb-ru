# Único fluxo de débito/registro/comando para modo comum e FastPass.
# Ponto de integração com #6/#7: não existe outro mecanismo publicado na base auditada.
class ValidacaoDeAcesso
  class EventoIncompativel < StandardError; end

  MODOS = %w[FastPass Comum].freeze

  def self.processar!(catraca:, matricula:, chave:, modo: "FastPass", agora: Time.current, dispositivo: Catracas.dispositivo)
    new(catraca: catraca, matricula: matricula, chave: chave, modo: modo, agora: agora, dispositivo: dispositivo).processar!
  rescue ActiveRecord::RecordNotUnique
    # Outra requisição concorrente gravou a mesma chave de idempotência antes desta transação:
    # reexecuta o fluxo, com uma instância nova, para carregar o evento persistido e verificar compatibilidade.
    retry
  end

  def initialize(catraca:, matricula:, chave:, modo:, agora:, dispositivo:)
    @catraca = catraca
    @codigo = matricula.to_s.strip
    @chave = chave
    @modo = modo
    @agora = agora
    @dispositivo = dispositivo
  end

  def processar!
    validar_argumentos!
    evento = ProcessamentoAcesso.find_by(chave: @chave) || registrar_decisao
    garantir_compatibilidade!(evento)
    evento.enviar_comando!(dispositivo: @dispositivo)
    evento
  end

  private

  def validar_argumentos!
    raise ArgumentError, "Modo inválido" unless MODOS.include?(@modo)
    raise ArgumentError, "Chave obrigatória" if @chave.blank?

    @agora = @agora.in_time_zone
  end

  def registrar_decisao
    ProcessamentoAcesso.transaction do
      # Lock pessimista no aluno e na catraca evita corrida entre duas leituras simultâneas
      # (duplo débito de saldo ou dupla liberação no mesmo ponto de acesso).
      aluno&.lock!
      @catraca.lock!
      evento = criar_evento
      registrar_historico(evento) if aluno
      debitar!(evento) if evento.liberado?
      evento
    end
  end

  def criar_evento
    motivo = motivo_do_bloqueio
    ProcessamentoAcesso.create!(chave: @chave, catraca: @catraca, aluno: aluno, matricula: matricula_esperada,
      modo: @modo, data_hora: @agora, liberado: motivo.nil?, motivo: motivo || "Validação concluída")
  end

  # Primeiro motivo que impede a passagem; nil libera.
  def motivo_do_bloqueio
    return "Catraca offline" unless @catraca.online?
    return "Dispositivo de catraca indisponível" unless @dispositivo.disponivel?
    return "Aluno não encontrado" unless aluno
    return "Fora do turno de refeição" unless turno

    motivo_do_fastpass || ("Saldo insuficiente" if aluno.saldo < tarifa)
  end

  def motivo_do_fastpass
    return unless @modo == "FastPass"

    RegraFastpass.motivo_bloqueio(aluno: aluno, catraca: @catraca, turno: turno, agora: @agora)
  end

  # Projeção de leitura de #7/#9, gravada na mesma transação da decisão:
  # o histórico local e o relatório global leem estes campos direto,
  # sem passar por ProcessamentoAcesso.
  def registrar_historico(evento)
    historico = @catraca.historicos_catraca.create!(aluno: aluno, data_hora: @agora, modo_validacao: @modo,
      status: evento.liberado? ? "Liberado" : "Bloqueado", tarifa: tarifa_cobrada(evento), motivo: evento.motivo)
    evento.update!(historico_catraca: historico)
  end

  def tarifa_cobrada(evento) = evento.liberado? ? tarifa : 0

  def debitar!(evento)
    aluno.update!(saldo: aluno.saldo - tarifa)
    evento.update!(transacao: registrar_transacao)
  end

  # Débito que aparece no extrato do aluno.
  def registrar_transacao
    restaurante = @catraca.restaurante
    aluno.transacoes.create!(catraca: @catraca, restaurante: restaurante, refeicao: refeicao_do_turno(restaurante),
      data_hora: @agora, tipo: turno.nome, metodo: @modo, valor: -tarifa)
  end

  def refeicao_do_turno(restaurante)
    restaurante.refeicoes.find_by(data: @agora.to_date, tipo_refeicao: turno)
  end

  # A mesma chave só pode ser reaproveitada pela mesma leitura (catraca, aluno e modo).
  def garantir_compatibilidade!(evento)
    return if evento.catraca_id == @catraca.id && evento.matricula == matricula_esperada && evento.modo == @modo

    raise EventoIncompativel, "Evento já utilizado em outra leitura"
  end

  # O operador pode digitar a matrícula ou ler o QR Code da carteirinha.
  def aluno
    return @aluno if defined?(@aluno)

    @aluno = User.aluno.find_by(matricula: @codigo) || User.aluno.find_by(qr_code: @codigo)
  end

  def matricula_esperada = aluno&.matricula || @codigo

  def turno
    return @turno if defined?(@turno)

    @turno = TipoRefeicao.vigente_em(@agora)
  end

  # Cada turno tem sua própria tarifa; o débito é sempre o do turno da leitura.
  def tarifa = @tarifa ||= TarifaRefeicao.do_turno(turno)
end
