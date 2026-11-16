module Operador
  class PontosDeAcessoController < BaseController
    def edit
      @restaurantes = Restaurante.includes(:catracas).order(:nome)
    end

    def update
      session.delete(:catraca_em_operacao_id)
      restaurante = Restaurante.find_by(id: params[:restaurante_id])
      catraca = restaurante&.catracas&.find_by(id: params[:catraca_id])
      if !catraca
        flash.now[:alert] = "Selecione um restaurante e uma catraca pertencente a ele"
      elsif !catraca.online?
        flash.now[:alert] = "#{catraca.identificacao} está offline e não pode ser operada"
      else
        session[:catraca_em_operacao_id] = catraca.id
        return redirect_to terminal_de_validacao_path, status: :see_other
      end
      edit
      render :edit, status: :unprocessable_entity
    end
  end
end
