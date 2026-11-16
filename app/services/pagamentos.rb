module Pagamentos
  # Demonstração local, sem dados bancários. Nunca aprova créditos em produção.
  class Simulado
    def cobrar(chave:, valor:, metodo:) = :aprovado
  end

  class Indisponivel
    def cobrar(chave:, valor:, metodo:) = :pendente
  end

  def self.provedor
    Rails.configuration.x.provedor_pagamento || (Rails.env.local? ? Simulado.new : Indisponivel.new)
  end
end
