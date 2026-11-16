require "rails_helper"

RSpec.describe Refeicao, type: :model do
  let(:universidade) { Universidade.create!(nome: "Universidade de Brasília") }
  let(:campus) { universidade.campi.create!(nome: "Darcy Ribeiro") }
  let(:restaurante) { Restaurante.create!(campus: campus, nome: "RU Darcy Ribeiro") }

  describe "#opcoes_estruturadas" do
    it "normaliza 'OU' para 'ou' nas bebidas e monta os painéis de café da manhã" do
      cafe = TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30")
      refeicao = described_class.create!(
        restaurante: restaurante,
        tipo_refeicao: cafe,
        data: Date.new(2026, 11, 16),
        opcao_normal: "Ovos mexidos",
        opcao_ovolactovegetariana: "Queijo minas",
        opcao_vegetariana_estrita: "Homus de grão-de-bico",
        itens_extras: {
          "bebidas" => [ "Café OU chá", "Leite OU bebida de soja" ],
          "fruta" => "Banana"
        }
      )

      opcoes = refeicao.opcoes_estruturadas
      expect(opcoes.map { |o| o[:titulo] }).to eq([
        "Opção padrão",
        "Opção ovolactovegetariana",
        "Opção vegetariana estrita"
      ])

      opcoes.each do |opcao|
        expect(opcao[:linhas]).to include([ "Bebidas", "Café ou chá · Leite ou bebida de soja" ])
        expect(opcao[:linhas]).to include([ "Fruta", "Banana" ])
      end
      expect(opcoes.first[:linhas].first).to eq([ "Complemento", "Ovos mexidos" ])
    end

    it "agrupa salada_1 e salada_2 na categoria única 'Salada' e repete acompanhamentos" do
      almoco = TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30")
      refeicao = described_class.create!(
        restaurante: restaurante,
        tipo_refeicao: almoco,
        data: Date.new(2026, 11, 16),
        opcao_normal: "Frango assado",
        opcao_ovolactovegetariana: "Omelete de forno",
        opcao_vegetariana_estrita: "Quibe de abóbora",
        itens_extras: {
          "salada_1" => "Alface lisa",
          "salada_2" => "Tomate",
          "acompanhamentos" => [ "Arroz branco", "Feijão carioca" ]
        }
      )

      opcoes = refeicao.opcoes_estruturadas
      expect(opcoes.first[:linhas]).to eq([
        [ "Prato principal", "Frango assado" ],
        [ "Salada", "Alface lisa · Tomate" ],
        [ "Acompanhamentos", "Arroz branco · Feijão carioca" ]
      ])
      expect(opcoes.last[:linhas]).to include([ "Salada", "Alface lisa · Tomate" ])
    end
  end
end
