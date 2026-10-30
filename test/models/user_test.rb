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
end
