require "test_helper"

class HistoricoCatracaTest < ActiveSupport::TestCase
  setup do
    @universidade = Universidade.first || Universidade.create!(nome: "Universidade de Brasília")
    @campus = Campus.first || Campus.create!(nome: "Darcy Ribeiro", universidade: @universidade)
    @restaurante = Restaurante.first || Restaurante.create!(nome: "RU Darcy Ribeiro", campus: @campus)

    @catraca = Catraca.create!(
      numero: "04",
      piso: "2",
      restaurante: @restaurante
    )

    @aluno = User.create!(
      nome: "Estudante Teste",
      matricula: "211048992",
      password: "senha1234",
      password_confirmation: "senha1234",
      perfil: :aluno
    )
  end

  test "é válido com catraca, aluno e data_hora" do
    historico = HistoricoCatraca.new(
      catraca: @catraca,
      aluno: @aluno,
      data_hora: Time.current
    )

    assert historico.valid?
    assert_equal "Comum", historico.modo_validacao
    assert_equal 4.5, historico.tarifa.to_f
    assert_equal "Liberado", historico.status
  end

  test "exige catraca associada" do
    historico = HistoricoCatraca.new(
      aluno: @aluno,
      data_hora: Time.current
    )

    assert_not historico.valid?
    assert_includes historico.errors[:catraca], "must exist"
  end

  test "exige aluno associado" do
    historico = HistoricoCatraca.new(
      catraca: @catraca,
      data_hora: Time.current
    )

    assert_not historico.valid?
    assert_includes historico.errors[:aluno], "must exist"
  end
end
