require "rails_helper"

RSpec.describe "Cadastro de usuário", type: :request do
  def cadastrar(matricula: "2023123456", confirmacao: "senha123")
    post signup_path, params: { user: { nome: "Aluno Novo", matricula: matricula,
                                        password: "senha123", password_confirmation: confirmacao } }
  end

  it "exibe o formulário de cadastro" do
    get signup_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Cadastro de Usuário", "Nome Completo", "Confirmar Senha", "Criar Minha Conta")
  end

  it "cria o usuário e redireciona para o login" do
    expect { cadastrar }.to change(User, :count).by(1)
    expect(response).to redirect_to(login_path)
    expect(flash[:notice]).to eq("Cadastro realizado com sucesso. Faça login para continuar.")
    expect(User.find_by(matricula: "2023123456")).to have_attributes(nome: "Aluno Novo", perfil: "aluno")
  end

  it "não cria o usuário quando as senhas são diferentes" do
    expect { cadastrar(confirmacao: "senha456") }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(flash[:alert]).to eq("Não foi possível realizar cadastro")
  end

  it "não cria o usuário com matrícula já cadastrada" do
    existente = criar_usuario

    expect { cadastrar(matricula: existente.matricula) }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("já está cadastrada")
  end
end
