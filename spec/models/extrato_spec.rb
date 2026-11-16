require "rails_helper"

RSpec.describe Extrato do
  let(:aluno) { criar_usuario }

  def lancar(data_hora, tipo, valor, metodo: "QR Code App")
    aluno.transacoes.create!(data_hora: data_hora, tipo: tipo, valor: valor, metodo: metodo)
  end

  before do
    travel_to Time.zone.local(2024, 5, 14, 12, 30)

    lancar(Time.zone.local(2024, 5, 14, 12, 20), "Almoço", -4.5)
    lancar(Time.zone.local(2024, 5, 13, 19, 10), "Jantar", -4.5)
    lancar(Time.zone.local(2024, 5, 10, 14, 0), "Recarga de Saldo", 45, metodo: "PIX")
    lancar(Time.zone.local(2024, 4, 2, 12, 0), "Almoço", -4.5) # mês anterior
  end

  it "usa o mês atual como período padrão" do
    extrato = described_class.new(aluno)

    expect(extrato.data_inicial).to eq(Date.new(2024, 5, 1))
    expect(extrato.data_final).to eq(Date.new(2024, 5, 31))
    expect(extrato.total_registros).to eq(3)
  end

  it "calcula os indicadores do período" do
    extrato = described_class.new(aluno)

    expect(extrato.total_gasto).to eq(9.0)
    expect(extrato.total_refeicoes).to eq(2)
    expect(extrato.refeicoes_por_tipo).to eq({ "Almoço" => 1, "Jantar" => 1 })
    expect(extrato.total_recarregado).to eq(45.0)
    expect(extrato.quantidade_recargas).to eq(1)
  end

  it "aceita datas em dd/mm/aaaa e em ISO" do
    expect(described_class.new(aluno, data_inicial: "01/04/2024", data_final: "30/04/2024").total_registros).to eq(1)
    expect(described_class.new(aluno, data_inicial: "2024-04-01", data_final: "2024-04-30").total_registros).to eq(1)
  end

  it "ignora datas inválidas e volta ao padrão" do
    expect(described_class.new(aluno, data_inicial: "ontem").data_inicial).to eq(Date.new(2024, 5, 1))
  end

  it "filtra por tipo e método sem alterar os indicadores" do
    extrato = described_class.new(aluno, tipo: "Jantar")

    expect(extrato.total_registros).to eq(1)
    expect(extrato.total_refeicoes).to eq(2)
    expect(described_class.new(aluno, metodo: "PIX").total_registros).to eq(1)
  end

  it "pagina os lançamentos do mais recente para o mais antigo" do
    Extrato::POR_PAGINA.times { |i| lancar(Time.zone.local(2024, 5, 1, 8, i), "Café da Manhã", -2.5) }
    extrato = described_class.new(aluno)

    expect(extrato.total_registros).to eq(Extrato::POR_PAGINA + 3)
    expect(extrato.total_paginas).to eq(2)
    expect(extrato.transacoes.size).to eq(Extrato::POR_PAGINA)
    expect(extrato.transacoes.first.data_hora).to eq(Time.zone.local(2024, 5, 14, 12, 20))
    expect(described_class.new(aluno, pagina: 2).transacoes.size).to eq(3)
  end
end
