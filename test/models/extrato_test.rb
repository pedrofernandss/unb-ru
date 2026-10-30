require "test_helper"

class ExtratoTest < ActiveSupport::TestCase
  setup do
    @aluno = users(:genaina)
    travel_to Time.zone.local(2024, 5, 14, 12, 30)

    lancar(Time.zone.local(2024, 5, 14, 12, 20), "Almoço", -4.5)
    lancar(Time.zone.local(2024, 5, 13, 19, 10), "Jantar", -4.5)
    lancar(Time.zone.local(2024, 5, 10, 14, 0), "Recarga de Saldo", 45, metodo: "PIX")
    lancar(Time.zone.local(2024, 4, 2, 12, 0), "Almoço", -4.5) # mês anterior
  end

  test "usa o mês atual como período padrão" do
    extrato = Extrato.new(@aluno)

    assert_equal Date.new(2024, 5, 1), extrato.data_inicial
    assert_equal Date.new(2024, 5, 31), extrato.data_final
    assert_equal 3, extrato.total_registros
  end

  test "calcula os indicadores do período" do
    extrato = Extrato.new(@aluno)

    assert_equal 9.0, extrato.total_gasto
    assert_equal 2, extrato.total_refeicoes
    assert_equal({ "Almoço" => 1, "Jantar" => 1 }, extrato.refeicoes_por_tipo)
    assert_equal 45.0, extrato.total_recarregado
    assert_equal 1, extrato.quantidade_recargas
  end

  test "aceita datas em dd/mm/aaaa e em ISO" do
    assert_equal 1, Extrato.new(@aluno, data_inicial: "01/04/2024", data_final: "30/04/2024").total_registros
    assert_equal 1, Extrato.new(@aluno, data_inicial: "2024-04-01", data_final: "2024-04-30").total_registros
  end

  test "ignora datas inválidas e volta ao padrão" do
    assert_equal Date.new(2024, 5, 1), Extrato.new(@aluno, data_inicial: "ontem").data_inicial
  end

  test "filtra por tipo e método sem alterar os indicadores" do
    extrato = Extrato.new(@aluno, tipo: "Jantar")

    assert_equal 1, extrato.total_registros
    assert_equal 2, extrato.total_refeicoes
    assert_equal 1, Extrato.new(@aluno, metodo: "PIX").total_registros
  end

  test "pagina os lançamentos do mais recente para o mais antigo" do
    Extrato::POR_PAGINA.times { |i| lancar(Time.zone.local(2024, 5, 1, 8, i), "Café da Manhã", -2.5) }
    extrato = Extrato.new(@aluno)

    assert_equal Extrato::POR_PAGINA + 3, extrato.total_registros
    assert_equal 2, extrato.total_paginas
    assert_equal Extrato::POR_PAGINA, extrato.transacoes.size
    assert_equal Time.zone.local(2024, 5, 14, 12, 20), extrato.transacoes.first.data_hora
    assert_equal 3, Extrato.new(@aluno, pagina: 2).transacoes.size
  end

  private

  def lancar(data_hora, tipo, valor, metodo: "QR Code App")
    @aluno.transacoes.create!(data_hora: data_hora, tipo: tipo, valor: valor, metodo: metodo)
  end
end
