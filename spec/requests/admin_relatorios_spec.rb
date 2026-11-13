require "rails_helper"
require "pdf/reader"

RSpec.describe "Relatório global de acessos", type: :request do
  let(:darcy) { Restaurante.create!(nome: "RU Darcy Ribeiro", numero_de_pisos: 1) }
  let(:catraca) { darcy.catracas.create!(numero: 4, piso: 1) }
  let(:aluno) { criar_usuario }

  before do
    HistoricoCatraca.create!(catraca: catraca, aluno: aluno, data_hora: Time.zone.parse("2026-10-15 12:05"),
                             status: "Liberado", modo_validacao: "FastPass", tarifa: 4.5)
  end

  context "como administrador" do
    before { entrar_como(criar_usuario(perfil: :administrador)) }

    it "mostra os acessos e os totais" do
      get admin_relatorio_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(aluno.matricula, "Catraca 04", "R$ 4,50")
    end

    it "avisa quando o período está invertido" do
      get admin_relatorio_path, params: { data_inicial: "2026-10-16", data_final: "2026-10-14" }
      expect(response.body).to include("A data inicial deve ser anterior à data final")
      expect(response.body).not_to include(aluno.matricula)
    end

    it "oferece só as catracas do restaurante filtrado" do
      Restaurante.create!(nome: "RU Gama", numero_de_pisos: 1).catracas.create!(numero: 7, piso: 1)
      get admin_relatorio_path, params: { restaurante_id: darcy.id }
      expect(response.body).to include("Catraca 04")
      expect(response.body).not_to include("Catraca 07")
    end

    it "exporta o PDF com os filtros aplicados" do
      get admin_exportar_relatorio_path, params: { restaurante_id: darcy.id }
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("relatorio-global.pdf")

      texto = PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join("\n")
      expect(texto).to include("Relatório Global de Operação", "RU Darcy Ribeiro", "Catraca 04", aluno.matricula, "R$ 4,50")
    end

    it "não gera PDF sem acessos e mantém os filtros" do
      get admin_exportar_relatorio_path, params: { data_inicial: "2026-10-01", data_final: "2026-10-02" }
      expect(response).to redirect_to(admin_relatorio_path(data_inicial: "2026-10-01", data_final: "2026-10-02"))
      expect(flash[:alert]).to eq("Não há acessos para exportar no período selecionado")
    end

    it "não gera PDF com período invertido" do
      get admin_exportar_relatorio_path, params: { data_inicial: "2026-10-16", data_final: "2026-10-14" }
      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq("A data inicial deve ser anterior à data final")
    end
  end

  %i[aluno funcionario].each do |perfil|
    it "bloqueia o relatório e o PDF para #{perfil}" do
      entrar_como(criar_usuario(perfil: perfil))
      get admin_relatorio_path
      expect(response).to redirect_to(home_path)
      get admin_exportar_relatorio_path
      expect(response).to redirect_to(home_path)
    end
  end
end
