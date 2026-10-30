require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "exibe o formulário de cadastro" do
    get signup_path

    assert_response :success
    assert_select "h1", "Cadastro de Usuário"
    assert_select "label", "Nome Completo"
    assert_select "label", "Matrícula SIGAA ou SIAPE"
    assert_select "label", "Senha de Acesso"
    assert_select "label", "Confirmar Senha"
    assert_select "button[type=submit]", /Criar Minha Conta/
    assert_select "a[href=?]", login_path, "Acesse aqui"
  end

  test "cria o usuário e redireciona para o login" do
    assert_difference("User.count", 1) do
      post signup_path, params: { user: { nome: "Aluno Novo", matricula: "2023123456",
                                          password: "senha123", password_confirmation: "senha123" } }
    end

    assert_redirected_to login_path
    assert_equal "Aluno Novo", User.find_by(matricula: "2023123456").nome
  end

  test "não cria o usuário quando as senhas são diferentes" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: { nome: "Aluno Novo", matricula: "2023123456",
                                          password: "senha123", password_confirmation: "senha456" } }
    end

    assert_response :unprocessable_entity
    assert_select ".alerta--erro", /Não foi possível realizar cadastro/
    assert_select ".campo--erro label", "Confirmar Senha"
  end

  test "não cria o usuário com matrícula já cadastrada" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: { nome: "Outra Pessoa", matricula: users(:genaina).matricula,
                                          password: "senha123", password_confirmation: "senha123" } }
    end

    assert_response :unprocessable_entity
    assert_select ".alerta__lista li", /já está cadastrada/
  end
end
