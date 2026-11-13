require "rails_helper"

RSpec.describe "Gestão de restaurantes e catracas", type: :request do
  let!(:darcy) { Restaurante.create!(nome: "RU Darcy Ribeiro", numero_de_pisos: 3) }

  context "como administrador" do
    before { entrar_como(criar_usuario(perfil: :administrador)) }

    it "lista as unidades com as catracas agrupadas por piso" do
      darcy.catracas.create!(numero: 4, piso: 2)
      get admin_restaurantes_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RU Darcy Ribeiro", "piso-2", "Catraca 04")
    end

    it "cadastra um restaurante" do
      expect {
        post admin_restaurantes_path, params: { restaurante: { nome: "RU Gama", numero_de_pisos: "1" } }
      }.to change(Restaurante, :count).by(1)
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(flash[:notice]).to eq("Restaurante cadastrado com sucesso")
    end

    it "mostra os erros e não cadastra restaurante inválido" do
      expect {
        post admin_restaurantes_path, params: { restaurante: { nome: "RU Darcy Ribeiro", numero_de_pisos: "0" } }
      }.not_to change(Restaurante, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Já existe um restaurante com esse nome", "Número de Pisos deve ser maior que 0")
    end

    it "edita o nome de um restaurante" do
      patch admin_restaurante_path(darcy), params: { restaurante: { nome: "RU Darcy Ribeiro - Central" } }
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(darcy.reload.nome).to eq("RU Darcy Ribeiro - Central")
    end

    it "remove restaurante sem catracas" do
      expect { delete admin_restaurante_path(darcy) }.to change(Restaurante, :count).by(-1)
      expect(flash[:notice]).to eq("Restaurante removido com sucesso")
    end

    it "mantém restaurante que ainda tem catracas" do
      darcy.catracas.create!(numero: 1, piso: 1)
      expect { delete admin_restaurante_path(darcy) }.not_to change(Restaurante, :count)
      expect(flash[:alert]).to eq("Remova as catracas antes de excluir o restaurante")
    end

    it "associa uma catraca ao restaurante" do
      expect {
        post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "4", piso: "2" } }
      }.to change(darcy.catracas, :count).by(1)
      expect(flash[:notice]).to eq("Catraca associada com sucesso")
    end

    it "recusa catraca em piso inexistente" do
      expect {
        post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "4", piso: "4" } }
      }.not_to change(Catraca, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Piso deve estar entre 1 e 3")
    end

    it "remove uma catraca" do
      catraca = darcy.catracas.create!(numero: 2, piso: 1)
      expect { delete admin_catraca_path(catraca) }.to change(Catraca, :count).by(-1)
      expect(flash[:notice]).to eq("Catraca removida com sucesso")
    end
  end

  %i[aluno funcionario].each do |perfil|
    context "como #{perfil}" do
      before { entrar_como(criar_usuario(perfil: perfil)) }

      it "não acessa a gestão nem altera dados" do
        get admin_restaurantes_path
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to eq("Acesso restrito a administradores")

        expect { delete admin_restaurante_path(darcy) }.not_to change(Restaurante, :count)
        expect { post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "9", piso: "1" } } }
          .not_to change(Catraca, :count)
      end
    end
  end

  it "exige login" do
    get admin_restaurantes_path
    expect(response).to redirect_to(login_path)
  end
end
