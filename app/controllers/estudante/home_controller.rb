module Estudante
  class HomeController < BaseController
    def index
      @restaurantes = Restaurante.order(:nome)
      @restaurante = restaurante_selecionado
      @agora = Time.current
      @turno_atual = TipoRefeicao.vigente_em(@agora)
      @refeicao_atual = refeicao_atual
    end

    private

    # O restaurante escolhido no seletor ou, sem escolha válida, o primeiro da lista.
    def restaurante_selecionado
      (params[:restaurante_id].present? && @restaurantes.find_by(id: params[:restaurante_id])) || @restaurantes.first
    end

    # Cardápio do turno em andamento no restaurante selecionado, se houver.
    def refeicao_atual
      return unless @restaurante && @turno_atual

      @restaurante.refeicoes.find_by(data: @agora.to_date, tipo_refeicao: @turno_atual)
    end
  end
end
