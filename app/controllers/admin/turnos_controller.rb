module Admin
  # Gestão dos turnos (tipos de refeição) e dos time-frames do FastPass (US16).
  class TurnosController < BaseController
    def index
      @turnos = TipoRefeicao.order(:hora_inicio)
    end
  end
end
