module Admin
  module RelatoriosHelper
    # Catracas agrupadas por restaurante: vários restaurantes têm uma "Catraca 01".
    def opcoes_de_catraca
      Restaurante.includes(:catracas).order(:nome).to_h do |restaurante|
        [ restaurante.nome, restaurante.catracas.map { |catraca| [ catraca.identificacao, catraca.id ] } ]
      end
    end
  end
end
