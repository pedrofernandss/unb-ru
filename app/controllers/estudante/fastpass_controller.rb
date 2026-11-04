module Estudante
  # Sorteio do FastPass (US13): o aluno escolhe uma janela por turno.
  class FastpassController < BaseController
    def show
      @turnos = TipoRefeicao.where(id: TimeFrame.select(:tipo_refeicao_id))
                            .order(:hora_inicio).includes(:time_frames)
      @inscricoes = current_user.inscricoes_fastpass.where(data: Date.current)
                                .includes(time_frame: :tipo_refeicao)
                                .index_by { |inscricao| inscricao.time_frame.tipo_refeicao_id }
    end
  end
end
