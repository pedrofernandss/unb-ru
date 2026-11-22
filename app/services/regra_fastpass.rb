# Política exata da #15: início e fim inclusivos, sem tolerância de outro módulo.
class RegraFastpass
  def self.motivo_bloqueio(aluno:, catraca:, turno:, agora:)
    new(aluno: aluno, catraca: catraca, turno: turno, agora: agora).motivo_bloqueio
  end

  def initialize(aluno:, catraca:, turno:, agora:)
    @aluno = aluno
    @catraca = catraca
    @turno = turno
    @agora = agora
  end

  # Primeiro motivo que impede a passagem pelo FastPass; nil libera.
  def motivo_bloqueio
    return "Aluno sem contemplação para este dia e turno" unless inscricao
    return "Inscrição de outro restaurante" if outro_restaurante?
    return "Inscrição de outra refeição" if outra_refeicao?
    return "Janela indisponível" unless inscricao.time_frame

    "Fora do time-frame sorteado" unless dentro_da_janela?
  end

  private

  def inscricao
    return @inscricao if defined?(@inscricao)

    @inscricao = @aluno.inscricoes_fastpass.contemplado.joins(:time_frame)
      .where(data: @agora.to_date, time_frames: { tipo_refeicao_id: @turno.id }).first
  end

  def outro_restaurante?
    restaurante_id = inscricao.restaurante_id
    restaurante_id && restaurante_id != @catraca.restaurante_id
  end

  # Inscrição vinculada a uma refeição só vale para aquela data, restaurante e turno.
  def outra_refeicao?
    refeicao = inscricao.refeicao
    refeicao && [ refeicao.data, refeicao.restaurante_id, refeicao.tipo_refeicao_id ] !=
                [ @agora.to_date, @catraca.restaurante_id, @turno.id ]
  end

  def dentro_da_janela?
    janela = inscricao.time_frame
    @agora.between?(horario_na_data(janela.inicio), horario_na_data(janela.fim))
  end

  def horario_na_data(hora) = TipoRefeicao.horario_na_data(inscricao.data, hora)
end
