# Fake apenas no processo de testes; não há endpoint para escolher aprovação.
class ProvedorDePagamentoFake
  def initialize(resultado)
    @resultado = resultado
  end

  def cobrar(chave:, valor:, metodo:) = @resultado
end

After { Rails.configuration.x.provedor_pagamento = nil }
