require "rails_helper"

RSpec.describe Transacao, type: :model do
  let(:aluno) { criar_usuario }
  let(:restaurante) { criar_restaurante(nome: "RU Darcy Ribeiro") }

  def transacao(**atributos)
    aluno.transacoes.new(data_hora: Time.current, tipo: "Almoço", valor: -4.5, **atributos)
  end

  describe "#local e #detalhe_local" do
    it "na catraca mostra o restaurante, o piso e o número da catraca" do
      catraca = restaurante.catracas.create!(numero: 4, piso: 2)
      expect(transacao(catraca: catraca)).to have_attributes(local: "RU Darcy Ribeiro - Piso 2", detalhe_local: "Catraca 04")
    end

    it "sem catraca mostra só o restaurante" do
      expect(transacao(restaurante: restaurante)).to have_attributes(local: "RU Darcy Ribeiro", detalhe_local: nil)
    end

    it "na recarga mostra o crédito em carteira" do
      expect(transacao(tipo: "Recarga", valor: 20)).to have_attributes(local: "Recarga de saldo", detalhe_local: "Crédito em carteira")
    end
  end

  describe "validações" do
    it "é válida com data, tipo e valor" do
      expect(transacao).to be_valid
    end

    it "exige data, tipo e valor numérico" do
      invalida = aluno.transacoes.new(valor: "abc")
      expect(invalida).not_to be_valid
      expect(invalida.errors.of_kind?(:data_hora, :blank)).to be(true)
      expect(invalida.errors.of_kind?(:tipo, :blank)).to be(true)
      expect(invalida.errors.of_kind?(:valor, :not_a_number)).to be(true)
    end
  end
end
