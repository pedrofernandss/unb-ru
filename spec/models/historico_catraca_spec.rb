# frozen_string_literal: true

require "rails_helper"

RSpec.describe HistoricoCatraca, type: :model do
  let(:restaurante) { criar_restaurante }
  let(:catraca) { restaurante.catracas.create!(numero: 4, piso: 1, online: true) }
  let(:aluno) { criar_usuario(perfil: :aluno) }

  subject(:historico) do
    described_class.new(
      catraca: catraca,
      aluno: aluno,
      data_hora: Time.current,
      modo_validacao: "Comum",
      status: "Liberado",
      tarifa: BigDecimal("4.50")
    )
  end

  it "é válido com catraca, aluno, data_hora, modo_validacao, status e tarifa" do
    expect(historico).to be_valid
  end

  it "exige catraca associada" do
    historico.catraca = nil

    expect(historico).not_to be_valid
    expect(historico.errors.of_kind?(:catraca, :blank)).to be(true)
  end

  it "exige aluno associado" do
    historico.aluno = nil

    expect(historico).not_to be_valid
    expect(historico.errors.of_kind?(:aluno, :blank)).to be(true)
  end

  it "valida inclusão de modo_validacao e status e tarifa não negativa" do
    historico.modo_validacao = "Invalido"
    expect(historico).not_to be_valid

    historico.modo_validacao = "FastPass"
    historico.status = "Outro"
    expect(historico).not_to be_valid

    historico.status = "Bloqueado"
    historico.tarifa = -1
    expect(historico).not_to be_valid
  end
end
