require "rails_helper"

RSpec.describe "Autenticação do portal", type: :request do
  let(:aluno) { criar_usuario }

  def entrar(usuario, senha: "senha123")
    post login_path, params: { matricula: usuario.matricula, senha: senha }
  end

  it "exige login e mantém o fluxo de sessão existente" do
    get extrato_path
    expect(response).to redirect_to(login_path)
    entrar_como(criar_usuario)
    get extrato_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Extrato e Histórico de Refeições")
  end

  it "exibe o formulário de login" do
    get login_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Acesso ao Sistema", "Matrícula SIGAA ou SIAPE", "Entrar no Sistema")
  end

  it "leva quem já está logado direto para a sua área" do
    entrar(aluno)
    get login_path
    expect(response).to redirect_to(home_path)
  end

  it "leva cada perfil para a sua área depois do login" do
    entrar(aluno)
    expect(response).to redirect_to(home_path)
    delete logout_path

    entrar(criar_usuario(perfil: :funcionario))
    expect(response).to redirect_to(configuracao_de_ponto_path)
    delete logout_path

    entrar(criar_usuario(perfil: :administrador))
    expect(response).to redirect_to(admin_restaurantes_path)
  end

  it "volta para a página pedida antes do login" do
    get extrato_path
    entrar(aluno)
    expect(response).to redirect_to(extrato_url)
  end

  it "mantém na tela de login com senha incorreta ou matrícula inexistente" do
    entrar(aluno, senha: "errada")
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Matrícula ou senha inválidos.")

    post login_path, params: { matricula: "0000000", senha: "senha123" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(flash[:alert]).to eq("Matrícula ou senha inválidos.")
  end

  it "encerra a sessão ao sair" do
    entrar(aluno)
    delete logout_path
    expect(response).to redirect_to(login_path)
    expect(flash[:notice]).to eq("Você saiu do sistema.")

    get extrato_path
    expect(response).to redirect_to(login_path)
  end

  # O atalho mostra o primeiro usuário de cada perfil; o banco de teste pode ter outros além destes.
  it "mostra o atalho de um usuário por perfil só em desenvolvimento" do
    aluno
    criar_usuario(perfil: :funcionario)

    get login_path
    expect(response.body).not_to include("Atalho de desenvolvimento")

    allow(Rails.env).to receive(:development?).and_return(true)
    get login_path
    expect(response.body).to include("Atalho de desenvolvimento", "· aluno ·", "· funcionario ·")
  end
end
