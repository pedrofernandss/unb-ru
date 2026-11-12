require "test_helper"

class ValidacaoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @funcionario = User.create!(
      nome: "Funcionário Teste",
      matricula: "1234567",
      password: "senha1234",
      password_confirmation: "senha1234",
      perfil: :funcionario
    )

    @aluno = User.create!(
      nome: "Aluno Teste",
      matricula: "26100088",
      password: "senha1234",
      password_confirmation: "senha1234",
      perfil: :aluno,
      saldo: 15.0,
      qr_code: "QR_VALIDO_123"
    )
  end

  test "bloqueia acesso de usuário com perfil aluno" do
    entrar_como(@aluno)
    get validacao_path

    assert_redirected_to root_path
  end

  test "permite acesso de funcionário à tela de validação" do
    entrar_como(@funcionario)
    get validacao_path

    assert_response :success
    assert_match "Catraca Atual", response.body
  end

  test "debita saldo e libera passagem quando QR Code tem saldo suficiente" do
    entrar_como(@funcionario)
    post validacao_path, params: { qr_code: @aluno.qr_code }

    assert_redirected_to validacao_path
    assert_equal "Liberado", flash[:status_catraca]
    assert_equal(15.0 - User::PRECO_REFEICAO, @aluno.reload.saldo.to_f)
  end

  test "bloqueia passagem e mantém saldo quando saldo é insuficiente" do
    @aluno.update!(saldo: 2.0)
    entrar_como(@funcionario)
    post validacao_path, params: { qr_code: @aluno.qr_code }

    assert_redirected_to validacao_path
    assert_equal "Bloqueado", flash[:status_catraca]
    assert_equal 2.0, @aluno.reload.saldo.to_f
  end

  test "bloqueia passagem quando QR Code não existe" do
    entrar_como(@funcionario)
    post validacao_path, params: { qr_code: "QRCODE_INEXISTENTE" }

    assert_redirected_to validacao_path
    assert_equal "Bloqueado", flash[:status_catraca]
  end
end
