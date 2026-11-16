# Consulta do Relatório Global de Acessos (#9), usada pela tela e pelo PDF (#12).
class RelatorioGlobal
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :restaurante_id, :integer
  attribute :catraca_id, :integer
  attribute :data_inicial, :date
  attribute :data_final, :date
  attribute :pagina, :integer, default: 1

  POR_PAGINA = 50

  validate :periodo_em_ordem

  Consolidacao = Struct.new(:restaurante, :acessos, :liberados, :fastpass, :arrecadacao)
  ConsolidacaoDaCatraca = Struct.new(:catraca, :acessos, :liberados, :fastpass, :arrecadacao)

  # Todos os acessos dos filtros: base dos totais e do PDF, que é o documento de auditoria.
  def acessos
    @acessos ||= consultar
  end

  # A tela mostra uma página por vez; o histórico cresce a cada leitura de catraca.
  def acessos_da_pagina
    acessos.offset((pagina_atual - 1) * POR_PAGINA).limit(POR_PAGINA)
  end

  def pagina_atual = (pagina || 1).clamp(1, total_paginas)
  def total_paginas = [ (total_acessos.to_f / POR_PAGINA).ceil, 1 ].max
  def primeiro_da_pagina = total_acessos.zero? ? 0 : (pagina_atual - 1) * POR_PAGINA + 1
  def ultimo_da_pagina = [ pagina_atual * POR_PAGINA, total_acessos ].min

  def total_acessos = @total_acessos ||= acessos.count
  def refeicoes_servidas = acessos.liberados.count
  def acessos_fastpass = acessos.fastpass.count
  def arrecadacao = acessos.liberados.sum(:tarifa)

  def consolidacao
    somas = somar_por("catracas.restaurante_id")

    Restaurante.where(id: somas.keys).order(:nome).map do |restaurante|
      Consolidacao.new(restaurante, *somas[restaurante.id])
    end
  end

  # Agrupamento por catraca pedido na #9, na ordem da gestão: unidade, piso e número.
  def consolidacao_por_catraca
    somas = somar_por("historicos_catraca.catraca_id")
    catracas = Catraca.where(id: somas.keys).includes(:restaurante).joins(:restaurante)

    catracas.order("restaurantes.nome", :piso, :numero).map do |catraca|
      ConsolidacaoDaCatraca.new(catraca, *somas[catraca.id])
    end
  end

  def restaurante = (Restaurante.find_by(id: restaurante_id) if restaurante_id)
  def catraca = (Catraca.find_by(id: catraca_id) if catraca_id)

  # Para repassar os filtros da tela ao botão de exportação.
  def parametros
    attributes.except("pagina").compact.transform_values(&:to_s)
  end

  private

  # { id => [acessos, liberados, fastpass, arrecadação] }, somado no banco sem carregar os acessos.
  def somar_por(coluna)
    grupos = acessos.unscope(:order, :includes).group(coluna)
    liberados = grupos.liberados.count
    fastpass = grupos.fastpass.count
    arrecadado = grupos.liberados.sum(:tarifa)

    grupos.count.to_h do |id, total|
      [ id, [ total, liberados.fetch(id, 0), fastpass.fetch(id, 0), arrecadado.fetch(id, 0) ] ]
    end
  end

  def consultar
    return HistoricoCatraca.none if invalid?

    consulta = HistoricoCatraca.joins(:catraca).includes(:aluno, catraca: :restaurante)
    consulta = consulta.where(catracas: { restaurante_id: restaurante_id }) if restaurante_id
    consulta = consulta.where(catraca_id: catraca_id) if catraca_id
    consulta = consulta.where(data_hora: data_inicial.beginning_of_day..) if data_inicial
    consulta = consulta.where(data_hora: ..data_final.end_of_day) if data_final
    consulta.order(data_hora: :desc, id: :desc)
  end

  def periodo_em_ordem
    return unless data_inicial && data_final && data_inicial > data_final

    errors.add(:base, "A data inicial deve ser anterior à data final")
  end
end
