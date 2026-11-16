require "rails_helper"

RSpec.describe "Autenticação do portal", type: :request do
  it "exige login e mantém o fluxo de sessão existente" do
    get extrato_path
    expect(response).to redirect_to(login_path)
    entrar_como(criar_usuario)
    get extrato_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Extrato e Histórico de Refeições")
  end
end
