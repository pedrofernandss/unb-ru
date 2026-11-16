require "rails_helper"

RSpec.describe Catraca, type: :model do
  let(:restaurante) { Restaurante.create!(nome: "RU Darcy Ribeiro", numero_de_pisos: 3) }
  subject(:catraca) { Catraca.new(restaurante: restaurante, numero: 4, piso: 2) }

  it "é válida dentro dos pisos do restaurante" do
    expect(catraca).to be_valid
  end

  it "se identifica com o número em dois dígitos" do
    expect(catraca.identificacao).to eq("Catraca 04")
  end

  it "exige um restaurante" do
    catraca.restaurante = nil
    expect(catraca).not_to be_valid
    expect(catraca.errors.full_messages).to include("Restaurante deve ser selecionado")
  end

  { 0 => "Piso deve estar entre 1 e 3", 4 => "Piso deve estar entre 1 e 3", "dois" => "Piso deve ser um número" }.each do |piso, mensagem|
    it "recusa o piso #{piso.inspect}" do
      catraca.piso = piso
      expect(catraca).not_to be_valid
      expect(catraca.errors.full_messages).to include(mensagem)
    end
  end

  it "recusa número repetido no mesmo restaurante" do
    restaurante.catracas.create!(numero: 4, piso: 1)
    expect(catraca).not_to be_valid
    expect(catraca.errors.full_messages).to eq([ "Já existe uma catraca com esse número neste restaurante" ])
  end

  it "aceita o mesmo número em outro restaurante" do
    outro = Restaurante.create!(nome: "RU Gama", numero_de_pisos: 1)
    outro.catracas.create!(numero: 4, piso: 1)
    expect(catraca).to be_valid
  end

  context "ao ser removida" do
    before { catraca.save! }

    it "é removida quando nunca registrou acessos" do
      expect { catraca.destroy }.to change(Catraca, :count).by(-1)
    end

    it "é mantida, com o histórico, quando já registrou acessos" do
      catraca.historicos_catraca.create!(aluno: criar_usuario, data_hora: Time.current, modo_validacao: "Comum",
                                         status: "Liberado", tarifa: 4.5)

      expect(catraca.destroy).to be(false)
      expect(catraca.errors.full_messages.first).to start_with("Esta catraca já registrou acessos")
      expect(catraca.historicos_catraca.count).to eq(1)
    end

    # Leitura de matrícula desconhecida: fica só o processamento, sem histórico.
    it "é mantida quando só tem leituras sem aluno identificado" do
      ProcessamentoAcesso.create!(chave: SecureRandom.uuid, catraca: catraca, matricula: "000000000", modo: "Comum",
                                  data_hora: Time.current, motivo: "Aluno não encontrado")

      expect(catraca.destroy).to be(false)
      expect(Catraca.exists?(catraca.id)).to be(true)
    end
  end

  it "recusa número que não seja inteiro positivo" do
    catraca.numero = "quatro"
    expect(catraca).not_to be_valid
    expect(catraca.errors[:numero]).to be_present
  end
end
