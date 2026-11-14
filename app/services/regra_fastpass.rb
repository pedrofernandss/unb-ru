# Política exata da #15: início e fim inclusivos, sem tolerância de outro módulo.
class RegraFastpass
  def self.motivo_bloqueio(aluno:, catraca:, turno:, agora:)
    inscricao = aluno.inscricoes_fastpass.contemplado.joins(:time_frame)
      .where(data: agora.to_date, time_frames: { tipo_refeicao_id: turno.id }).first
    return "Aluno sem contemplação para este dia e turno" unless inscricao
    return "Inscrição de outro restaurante" if inscricao.restaurante_id && inscricao.restaurante_id != catraca.restaurante_id

    if inscricao.refeicao && (inscricao.refeicao.data != agora.to_date ||
       inscricao.refeicao.restaurante_id != catraca.restaurante_id || inscricao.refeicao.tipo_refeicao_id != turno.id)
      return "Inscrição de outra refeição"
    end

    janela = inscricao.time_frame
    return "Janela indisponível" unless janela
    inicio = horario_na_data(inscricao.data, janela.inicio)
    fim = horario_na_data(inscricao.data, janela.fim)
    return "Fora do time-frame sorteado" unless agora.between?(inicio, fim)

    nil
  end

  def self.horario_na_data(data, hora)
    Time.zone.local(data.year, data.month, data.day, hora.hour, hora.min, hora.sec)
  end
end
