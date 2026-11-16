module Estudante
  class HomeController < BaseController
    def index
      @restaurantes = Restaurante.order(:nome)
      @restaurante = if params[:restaurante_id].present?
        @restaurantes.find_by(id: params[:restaurante_id])
      end
      @restaurante ||= @restaurantes.first

      @agora = Time.current
      @turno_atual = TipoRefeicao.vigente_em(@agora)
      @refeicao_atual = if @restaurante && @turno_atual
        @restaurante.refeicoes.find_by(data: @agora.to_date, tipo_refeicao: @turno_atual)
      end
    end
  end
end
