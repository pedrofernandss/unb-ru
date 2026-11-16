module Admin
  class CatracasController < BaseController
    def new
      @catraca = Catraca.new(restaurante_id: params[:restaurante_id], online: true)
    end

    def create
      @catraca = Catraca.new(catraca_params)

      if salvar_sem_duplicar(@catraca, :numero_em_uso) { @catraca.save }
        redirect_to admin_restaurantes_path, notice: "Catraca associada com sucesso"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @catraca = Catraca.find(params[:id])
    end

    # Só número e piso: o restaurante é fixo e a disponibilidade tem ação própria.
    def update
      @catraca = Catraca.find(params[:id])

      if salvar_sem_duplicar(@catraca, :numero_em_uso) { @catraca.update(params.expect(catraca: [ :numero, :piso ])) }
        redirect_to admin_restaurantes_path, notice: "Catraca atualizada com sucesso"
      else
        render :edit, status: :unprocessable_entity
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

    # Catraca offline não pode ser escolhida no Configurar Ponto e bloqueia as leituras no terminal.
    # Recebe o estado desejado, e não um "inverter": clique duplo ou reenvio não desfazem a ação.
    def disponibilidade
      catraca = Catraca.find(params[:id])
      catraca.update!(online: ActiveModel::Type::Boolean.new.cast(params.require(:online)))

      estado = catraca.online? ? "online" : "offline"
      redirect_to admin_restaurantes_path, notice: "#{catraca.identificacao} do #{catraca.restaurante.nome} está #{estado}"
    end

    private

    def catraca_params
      params.expect(catraca: [ :restaurante_id, :numero, :piso, :online ])
    end
  end
end
