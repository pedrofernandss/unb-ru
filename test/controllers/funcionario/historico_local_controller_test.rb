require "test_helper"

module Funcionario
  class HistoricoLocalControllerTest < ActionDispatch::IntegrationTest
    setup do
      @universidade = Universidade.first || Universidade.create!(nome: "Universidade de Brasília")
      @campus = Campus.first || Campus.create!(nome: "Darcy Ribeiro", universidade: @universidade)
      @restaurante = Restaurante.first || Restaurante.create!(nome: "RU Darcy Ribeiro", campus: @campus)

      @funcionario = User.create!(
        nome: "Funcionário Teste",
        matricula: "1234567",
        password: "senha1234",
        password_confirmation: "senha1234",
        perfil: :funcionario,
        catraca: nil
      )

      @aluno = User.create!(
        nome: "Discente Teste",
        matricula: "211048992",
        password: "senha1234",
        password_confirmation: "senha1234",
        perfil: :aluno
      )
    end

    test "bloqueia acesso de usuário com perfil aluno" do
      entrar_como(@aluno)
      get historico_local_path

      assert_redirected_to root_path
    end

    test "exibe mensagem de aviso quando funcionário não está gerindo catraca" do
      entrar_como(@funcionario)
      get historico_local_path

      assert_response :success
      assert_match "Você não está gerindo nenhuma catraca no momento", response.body
    end

    test "exibe apenas os acessos da catraca gerenciada pelo funcionário" do
      catraca_gerenciada = Catraca.create!(
        numero: "04",
        piso: "2",
        funcionario: @funcionario,
        restaurante: @restaurante
      )

      outra_catraca = Catraca.create!(
        numero: "09",
        piso: "1",
        restaurante: @restaurante
      )

      outro_aluno = User.create!(
        nome: "Outro Discente",
        matricula: "221012443",
        password: "senha1234",
        password_confirmation: "senha1234",
        perfil: :aluno
      )

      HistoricoCatraca.create!(
        catraca: catraca_gerenciada,
        aluno: @aluno,
        data_hora: Time.zone.parse("16/10/2026 12:18:22"),
        modo_validacao: "Comum",
        tarifa: 4.50,
        status: "Liberado"
      )

      HistoricoCatraca.create!(
        catraca: outra_catraca,
        aluno: outro_aluno,
        data_hora: Time.zone.parse("16/10/2026 12:19:00"),
        modo_validacao: "Comum",
        tarifa: 4.50,
        status: "Liberado"
      )

      entrar_como(@funcionario)
      get historico_local_path

      assert_response :success
      assert_match "04", response.body
      assert_match "211048992", response.body
      assert_match "R$4,50", response.body
      assert_no_match "221012443", response.body
    end
  end
end
