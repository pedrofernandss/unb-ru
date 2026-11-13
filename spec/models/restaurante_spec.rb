require "rails_helper"

RSpec.describe Restaurante, type: :model do
  subject(:restaurante) { Restaurante.new(nome: "RU Gama", numero_de_pisos: 1) }

  it "pode ser cadastrado sem campus" do
    expect(restaurante).to be_valid
  end

  it "exige nome" do
    restaurante.nome = ""
    expect(restaurante).not_to be_valid
    expect(restaurante.errors.full_messages).to include("Nome da Unidade não pode ficar em branco")
  end

  it "recusa nome repetido sem prefixar o nome do campo" do
    Restaurante.create!(nome: "RU Gama", numero_de_pisos: 2)
    expect(restaurante).not_to be_valid
    expect(restaurante.errors.full_messages).to eq([ "Já existe um restaurante com esse nome" ])
  end

  it "aceita manter o próprio nome ao editar" do
    restaurante.save!
    restaurante.numero_de_pisos = 2
    expect(restaurante).to be_valid
  end

  {
    nil => "Número de Pisos não pode ficar em branco",
    0 => "Número de Pisos deve ser maior que 0",
    "três" => "Número de Pisos deve ser um número",
    "1.5" => "Número de Pisos deve ser um número inteiro"
  }.each do |valor, mensagem|
    it "recusa #{valor.inspect} pisos" do
      restaurante.numero_de_pisos = valor
      expect(restaurante).not_to be_valid
      expect(restaurante.errors.full_messages).to include(mensagem)
    end
  end

  context "com catracas cadastradas" do
    before do
      restaurante.numero_de_pisos = 3
      restaurante.save!
      restaurante.catracas.create!(numero: 1, piso: 2)
    end

    it "não reduz os pisos abaixo do piso mais alto com catraca" do
      restaurante.numero_de_pisos = 1
      expect(restaurante).not_to be_valid
      expect(restaurante.errors[:numero_de_pisos]).to be_present
    end

    it "não pode ser removido" do
      expect(restaurante.destroy).to be(false)
      expect(restaurante.errors.full_messages).to eq([ "Remova as catracas antes de excluir o restaurante" ])
      expect(Restaurante.exists?(restaurante.id)).to be(true)
    end
  end

  it "é removido quando não tem catracas" do
    restaurante.save!
    expect { restaurante.destroy }.to change(Restaurante, :count).by(-1)
  end

  it "agrupa as catracas por piso em ordem de número" do
    restaurante.update!(numero_de_pisos: 2)
    restaurante.catracas.create!(numero: 3, piso: 2)
    restaurante.catracas.create!(numero: 1, piso: 1)
    restaurante.catracas.create!(numero: 2, piso: 2)

    expect(restaurante.reload.catracas_do_piso(2).map(&:numero)).to eq([ 2, 3 ])
  end
end
