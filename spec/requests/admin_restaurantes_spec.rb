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

    it "associa a catraca já online quando o campo vem marcado" do
      post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "4", piso: "2", online: "1" } }
      expect(darcy.catracas.find_by(numero: 4)).to be_online

      post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "5", piso: "2", online: "0" } }
      expect(darcy.catracas.find_by(numero: 5)).not_to be_online
    end

    it "coloca a catraca offline e de volta online" do
      catraca = darcy.catracas.create!(numero: 4, piso: 2, online: true)

      patch disponibilidade_admin_catraca_path(catraca), params: { online: false }
      expect(catraca.reload).not_to be_online
      expect(flash[:notice]).to eq("Catraca 04 do RU Darcy Ribeiro está offline")

      get admin_restaurantes_path
      expect(response.body).to include("Offline", "Colocar online")

      patch disponibilidade_admin_catraca_path(catraca), params: { online: true }
      expect(catraca.reload).to be_online
      expect(flash[:notice]).to eq("Catraca 04 do RU Darcy Ribeiro está online")
    end

    it "mantém a catraca offline quando o pedido de offline é reenviado" do
      catraca = darcy.catracas.create!(numero: 4, piso: 2, online: true)

      2.times { patch disponibilidade_admin_catraca_path(catraca), params: { online: false } }
      expect(catraca.reload).not_to be_online
    end

    it "mantém a catraca que já registrou acessos" do
      catraca = darcy.catracas.create!(numero: 2, piso: 1)
      catraca.historicos_catraca.create!(aluno: criar_usuario, data_hora: Time.current, modo_validacao: "Comum",
                                         status: "Liberado", tarifa: 4.5)

      expect { delete admin_catraca_path(catraca) }.not_to change(HistoricoCatraca, :count)
      expect(Catraca.exists?(catraca.id)).to be(true)
      expect(flash[:alert]).to include("já registrou acessos e não pode ser removida")
    end

    it "pede confirmação antes de remover unidade ou catraca" do
      darcy.catracas.create!(numero: 4, piso: 2)
      get admin_restaurantes_path
      expect(response.body).to include("Remover o RU Darcy Ribeiro?", "Remover a Catraca 04 do RU Darcy Ribeiro?")
    end

    it "trata como nome repetido a duplicata barrada só pelo índice único" do
      allow_any_instance_of(Restaurante).to receive(:nome_unico)

      expect {
        post admin_restaurantes_path, params: { restaurante: { nome: "RU Darcy Ribeiro", numero_de_pisos: "1" } }
      }.not_to change(Restaurante, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Já existe um restaurante com esse nome")
    end

    it "trata como número repetido a catraca barrada só pelo índice único" do
      darcy.catracas.create!(numero: 4, piso: 1)
      allow_any_instance_of(Catraca).to receive(:numero_unico_no_restaurante)

      expect {
        post admin_catracas_path, params: { catraca: { restaurante_id: darcy.id, numero: "4", piso: "2" } }
      }.not_to change(Catraca, :count)
      expect(response.body).to include("Já existe uma catraca com esse número neste restaurante")
    end

    it "edita o número e o piso de uma catraca, mantendo restaurante e disponibilidade" do
      gama = Restaurante.create!(nome: "RU Gama", numero_de_pisos: 1)
      catraca = darcy.catracas.create!(numero: 2, piso: 1, online: true)

      get edit_admin_catraca_path(catraca)
      expect(response.body).to include("Editar Catraca 02 do RU Darcy Ribeiro")

      patch admin_catraca_path(catraca), params: { catraca: { numero: "5", piso: "3", restaurante_id: gama.id, online: "0" } }
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(flash[:notice]).to eq("Catraca atualizada com sucesso")
      expect(catraca.reload).to have_attributes(numero: 5, piso: 3, restaurante_id: darcy.id, online: true)
    end

    it "recusa edição para piso inexistente ou número repetido" do
      darcy.catracas.create!(numero: 1, piso: 1)
      catraca = darcy.catracas.create!(numero: 2, piso: 1)

      patch admin_catraca_path(catraca), params: { catraca: { numero: "1", piso: "4" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Piso deve estar entre 1 e 3", "Já existe uma catraca com esse número neste restaurante")
      expect(catraca.reload).to have_attributes(numero: 2, piso: 1)
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

        catraca = darcy.catracas.create!(numero: 1, piso: 1, online: true)
        patch disponibilidade_admin_catraca_path(catraca), params: { online: false }
        patch admin_catraca_path(catraca), params: { catraca: { numero: "8", piso: "2" } }
        expect(catraca.reload).to have_attributes(online: true, numero: 1, piso: 1)
      end
    end
  end

  it "exige login" do
    get admin_restaurantes_path
    expect(response).to redirect_to(login_path)
  end
end
