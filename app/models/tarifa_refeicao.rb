# Tarifa das refeições dos aceites #2/#15. O preço em si é atributo do turno
# (TipoRefeicao#tarifa); esta classe responde às duas perguntas que o resto do
# sistema faz e mantém a regra em um único lugar no servidor.
class TarifaRefeicao
  # Vale enquanto não houver turno cadastrado (banco recém-criado, cenários de teste).
  PADRAO = BigDecimal("4.50")

  # Preço unitário de um pacote de recarga. Usa a maior tarifa vigente para que
  # N refeições compradas cubram N refeições de qualquer turno; a diferença de um
  # turno mais barato fica como saldo na carteira.
  def self.referencia
    TipoRefeicao.maximum(:tarifa) || PADRAO
  end

  # Valor debitado na catraca, pelo turno em que a leitura aconteceu.
  def self.do_turno(turno)
    turno&.tarifa || PADRAO
  end
end
