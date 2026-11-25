require "rails_helper"

RSpec.describe Cartao, type: :model do
  let(:aluno) { criar_usuario }

  def cartao(dono: aluno, **atributos)
    dono.cartoes.new(numero: "4111111111111111", bandeira: "Visa", nome: "ALUNO TESTE",
                     validade: Date.new(2030, 12, 1), codigo_verificacao: "123", **atributos)
  end

  it "é válido com os dados do cartão e começa com saldo zero" do
    expect(cartao).to be_valid
    expect(cartao.saldo).to eq(0)
  end

  it "exige aluno, número, bandeira, nome, validade e código de verificação" do
    vazio = described_class.new
    expect(vazio).not_to be_valid
    %i[aluno numero bandeira nome validade codigo_verificacao].each do |campo|
      expect(vazio.errors.of_kind?(campo, :blank)).to be(true), "#{campo} deveria ser obrigatório"
    end
  end

  it "recusa o mesmo número duas vezes para o mesmo aluno, mas aceita para outro aluno" do
    cartao.save!

    repetido = cartao
    expect(repetido).not_to be_valid
    expect(repetido.errors.of_kind?(:numero, :taken)).to be(true)
    expect(cartao(dono: criar_usuario)).to be_valid
  end

  it "recusa saldo negativo" do
    negativo = cartao(saldo: -1)
    expect(negativo).not_to be_valid
    expect(negativo.errors.of_kind?(:saldo, :greater_than_or_equal_to)).to be(true)
  end
end
