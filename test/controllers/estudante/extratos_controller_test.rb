require "test_helper"

class Estudante::ExtratosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aluno = users(:genaina)
  end

  test "exige login" do
    get extrato_path

    assert_redirected_to login_path
  end

  test "exibe indicadores, filtros e lançamentos do mês" do
    entrar_como @aluno
    transacao = @aluno.transacoes.create!(data_hora: Time.current, tipo: "Almoço", metodo: "QR Code App", valor: -4.5)

    get extrato_path

    assert_response :success
    assert_select "header nav a", "Extrato de Refeições"
    assert_select ".card", /Total gasto no mês/
    assert_select ".card", /Total de refeições realizadas/
    assert_select ".card", /Total recarregado/
    assert_select ".filtros-de-auditoria label", "Data inicial"
    assert_select "table thead th", "Refeição/Evento"
    assert_select "table tbody tr", 1
    assert_select "table tbody td", /-R\$ 4,50/
    assert_select "a[href=?]", comprovante_extrato_path(transacao), /Ver Comprovante/
  end

  test "mostra o estado vazio quando não há lançamentos no período" do
    entrar_como @aluno

    get extrato_path

    assert_response :success
    assert_select "table tbody tr", 0
    assert_select ".estado-vazio", /Não há lançamentos no período selecionado/
    assert_select ".card", /R\$ 0,00/
  end

  test "aplica o filtro de período" do
    entrar_como @aluno
    @aluno.transacoes.create!(data_hora: Time.zone.local(2024, 5, 14, 12, 20), tipo: "Almoço", metodo: "QR Code App", valor: -4.5)

    get extrato_path, params: { data_inicial: "01/05/2024", data_final: "31/05/2024" }

    assert_select "table tbody tr", 1
    assert_select "table tbody td", /14\/05\/2024 12:20/
  end

  test "não exibe o comprovante de outro aluno" do
    entrar_como @aluno
    outro = User.create!(nome: "Outro Aluno", matricula: "2023999999", password: "senha123")
    transacao = outro.transacoes.create!(data_hora: Time.current, tipo: "Almoço", valor: -4.5)

    get comprovante_extrato_path(transacao)

    assert_response :not_found
  end
end
