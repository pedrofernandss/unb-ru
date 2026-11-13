# Consulta do Relatório Global de Acessos (#9), usada pela tela e pelo PDF (#12).
class RelatorioGlobal
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :restaurante_id, :integer
  attribute :catraca_id, :integer
  attribute :data_inicial, :date
  attribute :data_final, :date

  validate :periodo_em_ordem

  Consolidacao = Struct.new(:restaurante, :acessos, :liberados, :fastpass, :arrecadacao)

  def acessos
    @acessos ||= consultar
  end

  def total_acessos = acessos.size
  def refeicoes_servidas = acessos.liberados.count
  def acessos_fastpass = acessos.fastpass.count
  def arrecadacao = acessos.liberados.sum(:tarifa)

  def consolidacao
    por_restaurante = acessos.group_by { |acesso| acesso.catraca.restaurante }
    por_restaurante.sort_by { |restaurante, _| restaurante.nome }.map do |restaurante, lista|
      liberados = lista.select { |acesso| acesso.status == "Liberado" }
      fastpass = lista.count { |acesso| acesso.modo_validacao == "FastPass" }
      Consolidacao.new(restaurante, lista.size, liberados.size, fastpass, liberados.sum(&:tarifa))
    end
  end

  def restaurante = (Restaurante.find_by(id: restaurante_id) if restaurante_id)
  def catraca = (Catraca.find_by(id: catraca_id) if catraca_id)

  # Para repassar os filtros da tela ao botão de exportação.
  def parametros
    attributes.compact.transform_values(&:to_s)
  end

  private

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
