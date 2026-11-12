require "test_helper"

class UserTest < ActiveSupport::TestCase
  def novo_usuario(**atributos)
    User.new({ nome: "Aluno Teste", matricula: "2023123456",
               password: "senha123", password_confirmation: "senha123" }.merge(atributos))
  end

  test "usuário com dados válidos é salvo" do
    assert novo_usuario.save
  end

  test "nome e matrícula são obrigatórios" do
    usuario = novo_usuario(nome: "", matricula: "")

    assert_not usuario.valid?
    assert_includes usuario.errors[:nome], "não pode ficar em branco"
    assert_includes usuario.errors[:matricula], "não pode ficar em branco"
  end

  test "matrícula aceita apenas números" do
    assert_not novo_usuario(matricula: "ABC123").valid?
    assert novo_usuario(matricula: " 1234567 ").valid?, "deve aceitar SIAPE com espaços em volta"
  end

  test "matrícula deve ser única" do
    usuario = novo_usuario(matricula: users(:genaina).matricula)

    assert_not usuario.valid?
    assert_includes usuario.errors[:matricula], "já está cadastrada"
  end

  test "senha e confirmação devem coincidir" do
    usuario = novo_usuario(password_confirmation: "senha456")

    assert_not usuario.valid?
    assert_includes usuario.errors.full_messages, "Confirmação de senha não confere com Senha"
  end

  test "senha deve ter ao menos 8 caracteres" do
    assert_not novo_usuario(password: "curta", password_confirmation: "curta").valid?
  end

  test "autentica com a senha correta" do
    assert users(:genaina).authenticate("senha123")
    assert_not users(:genaina).authenticate("errada")
  end

  test "verifica corretamente se o usuário tem saldo suficiente" do
    usuario_com_saldo = novo_usuario(saldo: User::PRECO_REFEICAO)
    usuario_sem_saldo = novo_usuario(saldo: User::PRECO_REFEICAO - 0.01)

    assert usuario_com_saldo.tem_saldo_suficiente?
    assert_not usuario_sem_saldo.tem_saldo_suficiente?
  end

  test "debita o preço da refeição quando há saldo suficiente" do
    usuario = novo_usuario(saldo: 20.0)
    usuario.save!

    assert usuario.debitar_refeicao!
    assert_equal(20.0 - User::PRECO_REFEICAO, usuario.reload.saldo.to_f)
  end

  test "não debita e retorna falso quando o saldo é insuficiente" do
    usuario = novo_usuario(saldo: 2.0)
    usuario.save!

    assert_not usuario.debitar_refeicao!
    assert_equal 2.0, usuario.reload.saldo.to_f
  end

  test "qr_code deve ser único quando informado" do
    novo_usuario(matricula: "2023000001", qr_code: "QR_UNICO_1").save!
    duplicado = novo_usuario(matricula: "2023000002", qr_code: "QR_UNICO_1")

    assert_not duplicado.valid?
    assert duplicado.errors[:qr_code].any?
  end
end
