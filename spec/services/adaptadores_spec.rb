require "rails_helper"

RSpec.describe "Adaptadores operacionais" do
  it "inicializa o pagamento simulado e a catraca simulada em ambiente local" do
    expect(Pagamentos.provedor).to be_a(Pagamentos::Simulado)
    expect(Catracas.dispositivo).to be_a(Catracas::Simulada)
  end

  it "mantém os adaptadores externos indisponíveis por padrão em produção" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new("production"))
    expect(Pagamentos.provedor.cobrar(chave: "teste", valor: 22.50, metodo: "PIX")).to eq(:pendente)
    expect(Catracas.dispositivo.disponivel?).to be(false)
  end
end
