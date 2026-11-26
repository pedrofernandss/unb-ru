require "rails_helper"

RSpec.describe ExtratosHelper, type: :helper do
  describe "#moeda_assinada" do
    it "mostra a recarga com sinal de mais" do
      expect(helper.moeda_assinada(BigDecimal("45"))).to eq("+R$ 45,00")
    end

    it "mostra o débito só com o sinal de menos" do
      expect(helper.moeda_assinada(BigDecimal("-4.5"))).to eq("-R$ 4,50")
    end
  end

  describe "#dia_relativo" do
    before { travel_to Time.zone.local(2026, 11, 25, 12, 0) }

    it "mostra Hoje e Ontem para os dois últimos dias" do
      expect(helper.dia_relativo(Time.zone.local(2026, 11, 25, 8, 0))).to eq("Hoje")
      expect(helper.dia_relativo(Time.zone.local(2026, 11, 24, 19, 0))).to eq("Ontem")
    end

    it "mostra o dia da semana para datas mais antigas" do
      expect(helper.dia_relativo(Time.zone.local(2026, 11, 23, 12, 0))).to eq("Segunda-feira")
    end
  end

  describe "#etiqueta_do_tipo" do
    it "usa a etiqueta de cada refeição e da recarga" do
      expect(helper.etiqueta_do_tipo("Almoço")).to eq("etiqueta--almoco")
      expect(helper.etiqueta_do_tipo("Jantar")).to eq("etiqueta--jantar")
      expect(helper.etiqueta_do_tipo("Café da manhã")).to eq("etiqueta--cafe")
      expect(helper.etiqueta_do_tipo("Recarga")).to eq("etiqueta--recarga")
    end

    it "usa a etiqueta neutra para tipo desconhecido ou vazio" do
      expect(helper.etiqueta_do_tipo("Estorno")).to eq("etiqueta--neutra")
      expect(helper.etiqueta_do_tipo(nil)).to eq("etiqueta--neutra")
    end
  end
end
