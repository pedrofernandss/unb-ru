require "prawn"

# Esqueleto comum dos PDFs do sistema (ExtratoPdf e RelatorioGlobalPdf): página A4,
# fonte padrão, numeração no rodapé e textos convertidos para Windows-1252.
# Quem inclui o módulo implementa #escrever_conteudo usando @pdf e #escrever.
module DocumentoPdf
  include ActionView::Helpers::NumberHelper

  MARGENS = [ 42, 40, 48, 40 ].freeze

  def render
    @pdf = Prawn::Document.new(page_size: "A4", margin: MARGENS)
    @pdf.font "Helvetica"
    escrever_conteudo
    @pdf.number_pages "Página <page> de <total>", at: [ 0, -22 ], align: :right, size: 9
    @pdf.render
  end

  private

  # Abre uma página nova quando não cabe mais um bloco da altura informada.
  def garantir_espaco(altura)
    @pdf.start_new_page if @pdf.cursor < altura
  end

  def escrever(valor, **opcoes)
    @pdf.text texto(valor), **opcoes
  end

  # As fontes PDF padrão suportam acentos portugueses em Windows-1252.
  # Caracteres fora desse alfabeto são substituídos, sem interromper a exportação.
  def texto(valor)
    valor.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?")
  end
end
