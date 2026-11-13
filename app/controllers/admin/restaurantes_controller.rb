module Admin
  class RestaurantesController < BaseController
    before_action :carregar_restaurante, only: %i[edit update destroy]

    def index
      @restaurantes = Restaurante.includes(:catracas).order(:nome)
    end

    def new
      @restaurante = Restaurante.new
    end

    def create
      @restaurante = Restaurante.new(restaurante_params)

      if @restaurante.save
        redirect_to admin_restaurantes_path, notice: "Restaurante cadastrado com sucesso"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @restaurante.update(restaurante_params)
        redirect_to admin_restaurantes_path, notice: "Restaurante atualizado com sucesso"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @restaurante.destroy
        redirect_to admin_restaurantes_path, notice: "Restaurante removido com sucesso"
      else
        redirect_to admin_restaurantes_path, alert: @restaurante.errors.full_messages.to_sentence
      end
    end

    private

    def carregar_restaurante
      @restaurante = Restaurante.find(params[:id])
    end

    def restaurante_params
      params.expect(restaurante: [ :nome, :numero_de_pisos ])
    end
  end
end
