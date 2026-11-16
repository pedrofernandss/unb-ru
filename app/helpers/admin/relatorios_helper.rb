module Admin
  module RelatoriosHelper
    # Agrupadas por restaurante porque vários têm uma "Catraca 01". O data-restaurante-id
    # é usado pelo catracas_do_restaurante_controller.js para esconder os outros grupos.
    # Todos os grupos vão para a página, mesmo com um restaurante filtrado: sem isso,
    # trocar o restaurante no seletor deixaria a lista de catracas vazia até filtrar de novo.
    def opcoes_de_catraca(relatorio)
      restaurantes = Restaurante.includes(:catracas).order(:nome)

      safe_join(restaurantes.map do |restaurante|
        opcoes = options_for_select(restaurante.catracas.map { |c| [ c.identificacao, c.id ] }, relatorio.catraca_id)
        tag.optgroup(opcoes, label: restaurante.nome, data: { restaurante_id: restaurante.id })
      end)
    end
  end
end
