module Admin
  class CatracasController < BaseController
    def new
      @catraca = Catraca.new(restaurante_id: params[:restaurante_id])
    end

    def create
      @catraca = Catraca.new(catraca_params)

      if @catraca.save
        redirect_to admin_restaurantes_path, notice: "Catraca associada com sucesso"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      catraca = Catraca.find(params[:id])

      if catraca.destroy
        redirect_to admin_restaurantes_path, notice: "Catraca removida com sucesso"
      else
        redirect_to admin_restaurantes_path, alert: catraca.errors.full_messages.to_sentence
      end
    end

    private

    def catraca_params
      params.expect(catraca: [ :restaurante_id, :numero, :piso ])
    end
  end
end
