module Operador
  class PontosDeAcessoController < BaseController
    def edit
      @restaurantes = Restaurante.includes(:catracas).order(:nome)
    end

    def update
      session.delete(:catraca_em_operacao_id)
      catraca = catraca_selecionada
      alerta = alerta_para(catraca)
      return iniciar_operacao(catraca) unless alerta

      flash.now[:alert] = alerta
      edit
      render :edit, status: :unprocessable_entity
    end

    private

    # A catraca precisa pertencer ao restaurante escolhido no formulário.
    def catraca_selecionada
      Restaurante.find_by(id: params[:restaurante_id])&.catracas&.find_by(id: params[:catraca_id])
    end

    # Motivo para não operar a catraca escolhida; nil quando ela pode ser operada.
    def alerta_para(catraca)
      return "Selecione um restaurante e uma catraca pertencente a ele" unless catraca

      "#{catraca.identificacao} está offline e não pode ser operada" unless catraca.online?
    end

    def iniciar_operacao(catraca)
      session[:catraca_em_operacao_id] = catraca.id
      redirect_to terminal_de_validacao_path, status: :see_other
    end
  end
end
