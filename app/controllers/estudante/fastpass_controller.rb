module Estudante
  # Sorteio do FastPass: o aluno escolhe uma janela por turno (US13) e vê o
  # resultado a partir de 1 hora antes do turno (US14).
  class FastpassController < BaseController
    before_action :exigir_aluno

    def show
      @turnos = turnos_com_janelas
      inscricoes = inscricoes_de_hoje
      @inscricoes = inscricoes.index_by { |inscricao| inscricao.time_frame.tipo_refeicao_id }
      avisar_inscricao_duplicada(inscricoes)
      @resultados = resultados_divulgados
    end

    private

    def turnos_com_janelas
      TipoRefeicao.where(id: TimeFrame.select(:tipo_refeicao_id)).includes(:time_frames).em_ordem
    end

    def inscricoes_de_hoje
      current_user.inscricoes_fastpass.where(data: Date.current).includes(time_frame: :tipo_refeicao).to_a
    end

    # Na ordem dos turnos, só as inscrições cujo resultado já foi divulgado.
    def resultados_divulgados
      @turnos.filter_map { |turno| @inscricoes[turno.id] }.select(&:resultado_liberado?)
    end

    # A página mostra uma inscrição por turno. Se a corrida documentada em InscricaoFastpass
    # criar duas no mesmo turno, uma fica escondida; o log deixa isso visível para o admin.
    def avisar_inscricao_duplicada(inscricoes)
      return if inscricoes.size == @inscricoes.size

      Rails.logger.warn("FastPass: aluno #{current_user.id} tem mais de uma inscrição no mesmo turno em #{Date.current}")
    end
  end
end
