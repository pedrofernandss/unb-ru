require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aluno = users(:genaina) # senha123
  end

  test "exibe o formulário de login" do
    get login_path

    assert_response :success
    assert_select "label", "Matrícula SIGAA ou SIAPE"
    assert_select "label", "Senha de Acesso"
    assert_select "button[type=submit]", /Entrar no Sistema/
  end

  test "aluno entra e vai para a página inicial do portal" do
    post login_path, params: { matricula: @aluno.matricula, senha: "senha123" }

    assert_redirected_to home_path
    follow_redirect!
    assert_select "header", /#{@aluno.nome}/
  end

  test "funcionário e administrador vão para as suas áreas" do
    funcionario = User.create!(nome: "Operador", matricula: "1111111", password: "senha123", perfil: :funcionario)
    post login_path, params: { matricula: funcionario.matricula, senha: "senha123" }
    assert_redirected_to configuracao_de_ponto_path

    delete logout_path

    admin = User.create!(nome: "Gestor", matricula: "2222222", password: "senha123", perfil: :administrador)
    post login_path, params: { matricula: admin.matricula, senha: "senha123" }
    assert_redirected_to admin_restaurantes_path
  end

  test "volta para a página pedida antes do login" do
    get extrato_path
    assert_redirected_to login_path

    post login_path, params: { matricula: @aluno.matricula, senha: "senha123" }

    assert_redirected_to extrato_url
  end

  test "senha incorreta ou matrícula inexistente mantém na tela com mensagem" do
    post login_path, params: { matricula: @aluno.matricula, senha: "errada" }
    assert_response :unprocessable_entity
    assert_select ".alerta--erro", /Matrícula ou senha inválidos\./

    post login_path, params: { matricula: "0000000", senha: "senha123" }
    assert_response :unprocessable_entity
  end

  test "sair encerra a sessão" do
    entrar_como @aluno
    delete logout_path

    assert_redirected_to login_path
    get extrato_path
    assert_redirected_to login_path
  end
end
