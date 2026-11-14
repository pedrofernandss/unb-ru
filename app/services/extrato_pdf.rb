require "prawn"

# Usa a mesma consulta das linhas da tela, sem offset/limit nem indicadores do período.
class ExtratoPdf
  def initialize(extrato)
    @extrato = extrato
  end

  def render
    pdf = Prawn::Document.new(page_size: "A4", margin: [ 42, 40, 48, 40 ])
    pdf.font "Helvetica"
    pdf.text texto("Extrato e Histórico de Refeições"), size: 18, style: :bold
    pdf.move_down 12
    pdf.text texto(@extrato.aluno.nome), size: 11
    pdf.text "#{@extrato.data_inicial.strftime('%d/%m/%Y')} a #{@extrato.data_final.strftime('%d/%m/%Y')}", size: 10
    filtros = [ @extrato.tipo, @extrato.metodo,
                @extrato.restaurantes_disponiveis.find_by(id: @extrato.restaurante_id)&.nome ].compact
    pdf.text texto("Filtros: #{filtros.join(' / ')}"), size: 10 if filtros.any?
    pdf.move_down 16

    @extrato.filtradas.recentes.includes(:restaurante, catraca: :restaurante).each do |transacao|
      pdf.start_new_page if pdf.cursor < 78
      pdf.text texto("#{transacao.data_hora.in_time_zone.strftime('%d/%m/%Y %H:%M')} | #{transacao.tipo}"), size: 11, style: :bold
      pdf.text texto("#{transacao.local} | #{transacao.metodo.presence || 'Método não informado'}"), size: 10
      pdf.text ActionController::Base.helpers.number_to_currency(transacao.valor), size: 11
      pdf.move_down 6
      pdf.stroke_horizontal_rule
      pdf.move_down 10
    end
    pdf.number_pages "Página <page> de <total>", at: [ 0, -22 ], align: :right, size: 9
    pdf.render
  end

  private

  # As fontes PDF padrão suportam acentos portugueses em Windows-1252.
  # Caracteres fora desse alfabeto são substituídos, sem interromper a exportação.
  def texto(valor)
    valor.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?")
  end
end
