module Admin
  module RelatoriosHelper
    # Agrupadas por restaurante porque vários têm uma "Catraca 01". O data-restaurante-id
    # é usado pelo catracas_do_restaurante_controller.js para esconder os outros grupos.
    def opcoes_de_catraca(relatorio)
      restaurantes = Restaurante.includes(:catracas).order(:nome)
      restaurantes = restaurantes.where(id: relatorio.restaurante_id) if relatorio.restaurante_id

      safe_join(restaurantes.map do |restaurante|
        opcoes = options_for_select(restaurante.catracas.map { |c| [ c.identificacao, c.id ] }, relatorio.catraca_id)
        tag.optgroup(opcoes, label: restaurante.nome, data: { restaurante_id: restaurante.id })
      end)
    end
  end
end
