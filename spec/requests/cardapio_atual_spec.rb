require "rails_helper"

RSpec.describe "Cardápio da refeição atual (/home)", type: :request do
  let(:universidade) { Universidade.create!(nome: "Universidade de Brasília") }
  let(:campus) { universidade.campi.create!(nome: "Darcy Ribeiro") }
  let!(:restaurante) { Restaurante.create!(campus: campus, nome: "RU Darcy Ribeiro") }

  let!(:cafe) { TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30") }
  let!(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30") }
  let!(:jantar) { TipoRefeicao.create!(nome: "Jantar", hora_inicio: "17:00", hora_fim: "19:30") }

  let(:aluno) do
    User.create!(
      nome: "Estudante Teste",
      matricula: "26100099",
      password: "senha123",
      perfil: :aluno
    )
  end

  before do
    post "/teste/sessao", params: { user_id: aluno.id }
  end

  it "exibe o cardápio do dia da semana e turno vigentes a partir dos dados semeados" do
    # Segunda-feira, 16/11/2026, horário de almoço
    Refeicao.create!(
      restaurante: restaurante,
      tipo_refeicao: almoco,
      data: Date.new(2026, 11, 16),
      opcao_normal: "Frango assado com manjericão",
      opcao_ovolactovegetariana: "Quiche de legumes e lentilha gratinada",
      opcao_vegetariana_estrita: "Refogado de lentilha, couve-flor e brócolis"
    )

    # Sexta-feira, 20/11/2026, horário de jantar
    Refeicao.create!(
      restaurante: restaurante,
      tipo_refeicao: jantar,
      data: Date.new(2026, 11, 20),
      opcao_normal: "Hambúrguer gratinado",
      opcao_ovolactovegetariana: "Nhoque ao molho branco com soja e queijo",
      opcao_vegetariana_estrita: "Moqueca de banana da terra com proteína de soja"
    )

    travel_to Time.zone.parse("2026-11-16 12:15:00") do
      get home_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Almoço")
      expect(response.body).to include("Frango assado com manjericão")
      expect(response.body).to include("Quiche de legumes e lentilha gratinada")
      expect(response.body).to include("Refogado de lentilha, couve-flor e brócolis")
      expect(response.body).not_to include("Hambúrguer gratinado")
    end

    travel_to Time.zone.parse("2026-11-20 18:30:00") do
      get home_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jantar")
      expect(response.body).to include("Hambúrguer gratinado")
      expect(response.body).to include("Nhoque ao molho branco com soja e queijo")
      expect(response.body).to include("Moqueca de banana da terra com proteína de soja")
    end
  end

  it "exibe 'Nenhum cardápio disponível' quando acessado fora do horário de refeição" do
    travel_to Time.zone.parse("2026-11-16 15:45:00") do
      get home_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nenhum cardápio disponível")
    end
  end
end
