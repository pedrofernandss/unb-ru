module Admin
  # Gestão dos turnos (tipos de refeição) e dos time-frames do FastPass (US16).
  # A edição acontece na própria página da lista, por isso edit e update renderizam :index.
  class TurnosController < BaseController
    before_action :carregar_turnos
    before_action :carregar_turno_em_edicao, only: %i[edit update]

    def index
    end

    # Não existe edit.html.haml: o formulário (_formulario_horario) aparece na própria lista.
    def edit
      render :index
    end

    def update
      if @turno_em_edicao.update(turno_params)
        redirect_to admin_turnos_path, notice: "Turno atualizado com sucesso"
      else
        flash.now[:alert] = "Não foi possível atualizar o turno"
        render :index, status: :unprocessable_entity
      end
    end

    def configurar_time_frames
      dados = params.expect(configuracao: [ :id, :granularidade_minutos, :tolerancia_minutos ])
      @turno_de_referencia = TipoRefeicao.find(dados[:id])

      if @turno_de_referencia.configurar_time_frames(granularidade: dados[:granularidade_minutos],
                                                     tolerancia: dados[:tolerancia_minutos])
        redirect_to admin_turnos_path, notice: "Time-frames gerados com sucesso"
      else
        flash.now[:alert] = "Não foi possível gerar os time-frames"
        render :index, status: :unprocessable_entity
      end
    end

    private

    # Consulta nova ao banco: a lista mostra sempre os horários salvos, mesmo
    # quando o turno em edição tem valores inválidos ainda não gravados.
    def carregar_turnos
      @turnos = TipoRefeicao.order(:hora_inicio).includes(:time_frames)
    end

    def carregar_turno_em_edicao
      @turno_em_edicao = TipoRefeicao.find(params[:id])
    end

    def turno_params
      params.expect(tipo_refeicao: [ :hora_inicio, :hora_fim ])
    end
  end
end
