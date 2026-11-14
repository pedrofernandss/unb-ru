require "rails_helper"

RSpec.describe TarifaRefeicao do
  it "usa o padrão enquanto não há turno cadastrado" do
    expect(TarifaRefeicao.referencia).to eq(BigDecimal("4.50"))
    expect(TarifaRefeicao.do_turno(nil)).to eq(BigDecimal("4.50"))
  end

  it "usa a maior tarifa como referência do pacote e a do próprio turno na catraca" do
    cafe = TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30", tarifa: "2.50")
    jantar = TipoRefeicao.create!(nome: "Jantar", hora_inicio: "17:00", hora_fim: "19:30", tarifa: "4.50")

    expect(TarifaRefeicao.referencia).to eq(4.50)
    expect(TarifaRefeicao.do_turno(cafe)).to eq(2.50)
    expect(TarifaRefeicao.do_turno(jantar)).to eq(4.50)
  end

  it "recusa turno com tarifa zerada ou negativa" do
    turno = TipoRefeicao.new(nome: "Ceia", hora_inicio: "21:00", hora_fim: "22:00", tarifa: 0)

    expect(turno).not_to be_valid
    expect(turno.errors[:tarifa]).to be_present
  end

  it "mantém a tarifa anterior como padrão para turnos já cadastrados" do
    turno = TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30")

    expect(turno.tarifa).to eq(BigDecimal("4.50"))
  end
end
