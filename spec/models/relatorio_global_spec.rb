require "rails_helper"

RSpec.describe RelatorioGlobal, type: :model do
  let(:darcy) { Restaurante.create!(nome: "RU Darcy Ribeiro", numero_de_pisos: 2) }
  let(:gama) { Restaurante.create!(nome: "RU Gama", numero_de_pisos: 1) }
  let(:catraca_darcy) { darcy.catracas.create!(numero: 1, piso: 1) }
  let(:catraca_darcy_2) { darcy.catracas.create!(numero: 4, piso: 2) }
  let(:catraca_gama) { gama.catracas.create!(numero: 1, piso: 1) }

  def acesso(catraca, data_hora, status: "Liberado", modo: "Comum", tarifa: 4.5)
    HistoricoCatraca.create!(catraca: catraca, aluno: criar_usuario, data_hora: Time.zone.parse(data_hora),
                             status: status, modo_validacao: modo, tarifa: status == "Liberado" ? tarifa : 0)
  end

  before do
    acesso(catraca_darcy, "2026-10-15 12:05")
    acesso(catraca_darcy_2, "2026-10-15 12:18", modo: "FastPass")
    acesso(catraca_darcy_2, "2026-10-15 12:20", status: "Bloqueado")
    acesso(catraca_gama, "2026-10-15 19:02", tarifa: 2.5)
  end

  it "soma apenas os acessos liberados nas refeições e na arrecadação" do
    relatorio = RelatorioGlobal.new
    expect(relatorio.total_acessos).to eq(4)
    expect(relatorio.refeicoes_servidas).to eq(3)
    expect(relatorio.arrecadacao).to eq(11.5)
    expect(relatorio.acessos_fastpass).to eq(1)
  end

  it "consolida por restaurante em ordem alfabética" do
    darcy_linha, gama_linha = RelatorioGlobal.new.consolidacao
    expect(darcy_linha.to_h.slice(:acessos, :liberados, :fastpass, :arrecadacao))
      .to eq(acessos: 3, liberados: 2, fastpass: 1, arrecadacao: 9)
    expect(gama_linha.restaurante).to eq(gama)
    expect(gama_linha.arrecadacao).to eq(2.5)
  end

  it "filtra por restaurante e por catraca" do
    expect(RelatorioGlobal.new(restaurante_id: gama.id).total_acessos).to eq(1)
    expect(RelatorioGlobal.new(catraca_id: catraca_darcy_2.id).total_acessos).to eq(2)
  end

  it "inclui o dia inteiro das datas do filtro" do
    expect(RelatorioGlobal.new(data_inicial: "15/10/2026", data_final: "15/10/2026").total_acessos).to eq(4)
    expect(RelatorioGlobal.new(data_final: "14/10/2026").total_acessos).to eq(0)
    expect(RelatorioGlobal.new(data_inicial: "16/10/2026").total_acessos).to eq(0)
  end

  it "recusa data inicial posterior à final e não retorna acessos" do
    relatorio = RelatorioGlobal.new(data_inicial: "16/10/2026", data_final: "14/10/2026")
    expect(relatorio).not_to be_valid
    expect(relatorio.errors.full_messages).to eq([ "A data inicial deve ser anterior à data final" ])
    expect(relatorio.acessos).to be_empty
  end

  it "lista os acessos do mais recente para o mais antigo" do
    expect(RelatorioGlobal.new.acessos.map { |a| a.data_hora.strftime("%H:%M") }).to eq(%w[19:02 12:20 12:18 12:05])
  end

  it "repassa só os filtros preenchidos" do
    expect(RelatorioGlobal.new(restaurante_id: "3", data_inicial: "01/10/2026").parametros)
      .to eq("restaurante_id" => "3", "data_inicial" => "2026-10-01")
  end
end
