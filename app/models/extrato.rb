# Extrato de um aluno: transações de um período com os demais filtros da tela,
# paginação e os totais exibidos nos indicadores. Não é uma tabela do banco.
class Extrato
  POR_PAGINA = 10

  attr_reader :aluno, :data_inicial, :data_final, :tipo, :restaurante_id, :metodo, :pagina

  def initialize(aluno, filtros = {})
    @aluno = aluno
    @data_inicial = interpretar_data(filtros[:data_inicial]) || Date.current.beginning_of_month
    @data_final = interpretar_data(filtros[:data_final]) || Date.current.end_of_month
    @tipo = filtros[:tipo].presence
    @restaurante_id = filtros[:restaurante_id].presence
    @metodo = filtros[:metodo].presence
    @pagina = [ filtros[:pagina].to_i, 1 ].max
  end

  # Transações do período, base dos indicadores.
  def no_periodo
    aluno.transacoes.no_periodo(data_inicial, data_final)
  end

  # Transações do período com os demais filtros, base da tabela.
  def filtradas
    escopo = no_periodo
    escopo = escopo.where(tipo: tipo) if tipo
    escopo = escopo.where(restaurante_id: restaurante_id) if restaurante_id
    escopo = escopo.where(metodo: metodo) if metodo
    escopo
  end

  def transacoes
    filtradas.recentes.includes(:restaurante, catraca: :restaurante)
             .offset((pagina - 1) * POR_PAGINA).limit(POR_PAGINA)
  end

  def total_registros = filtradas.count
  def total_paginas = [ (total_registros.to_f / POR_PAGINA).ceil, 1 ].max
  def primeiro_da_pagina = total_registros.zero? ? 0 : (pagina - 1) * POR_PAGINA + 1
  def ultimo_da_pagina = [ pagina * POR_PAGINA, total_registros ].min

  # Indicadores do período
  def total_gasto = -no_periodo.debitos.sum(:valor)
  def quantidade_debitos = no_periodo.debitos.count
  def total_refeicoes = quantidade_debitos
  def refeicoes_por_tipo = no_periodo.debitos.group(:tipo).order(:tipo).count
  def total_recarregado = no_periodo.creditos.sum(:valor)
  def quantidade_recargas = no_periodo.creditos.count

  # Opções dos filtros, a partir do histórico completo do aluno
  def tipos_disponiveis = aluno.transacoes.distinct.order(:tipo).pluck(:tipo)
  def metodos_disponiveis = aluno.transacoes.where.not(metodo: nil).distinct.order(:metodo).pluck(:metodo)
  def restaurantes_disponiveis = Restaurante.where(id: aluno.transacoes.select(:restaurante_id)).order(:nome)

  def filtros_ativos? = [ tipo, restaurante_id, metodo ].any?

  # Parâmetros da consulta atual, para montar links (paginação, exportação).
  def parametros
    { data_inicial: data_inicial.iso8601, data_final: data_final.iso8601,
      tipo: tipo, restaurante_id: restaurante_id, metodo: metodo }.compact
  end

  private

  # Aceita "2024-05-01" (input type=date) e "01/05/2024".
  def interpretar_data(valor)
    return if valor.blank?

    Date.parse(valor.to_s)
  rescue Date::Error
    nil
  end
end
