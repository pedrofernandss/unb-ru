require "prawn"

class RelatorioGlobalPdf
  include ActionView::Helpers::NumberHelper

  def initialize(relatorio)
    @relatorio = relatorio
  end

  def render
    pdf = Prawn::Document.new(page_size: "A4", margin: [ 42, 40, 48, 40 ])
    pdf.font "Helvetica"
    pdf.text texto("Relatório Global de Operação"), size: 18, style: :bold
    pdf.text texto("Emitido em #{I18n.l(Time.current)}"), size: 9
    pdf.move_down 8
    pdf.text texto("Filtros: #{descricao_dos_filtros}"), size: 10
    pdf.move_down 12

    pdf.text texto("Refeições servidas: #{@relatorio.refeicoes_servidas} de #{@relatorio.total_acessos} acessos"), size: 11
    pdf.text texto("Arrecadação global: #{number_to_currency(@relatorio.arrecadacao)}"), size: 11, style: :bold
    pdf.text texto("Acessos via FastPass: #{@relatorio.acessos_fastpass}"), size: 11
    pdf.move_down 12

    pdf.text texto("Consolidação por restaurante"), size: 13, style: :bold
    @relatorio.consolidacao.each do |linha|
      pdf.text texto("#{linha.restaurante.nome}: #{linha.liberados} liberados, #{linha.acessos - linha.liberados} bloqueados, " \
                     "#{linha.fastpass} FastPass, #{number_to_currency(linha.arrecadacao)}"), size: 10
    end
    pdf.move_down 12

    pdf.text texto("Acessos"), size: 13, style: :bold
    pdf.move_down 4
    @relatorio.acessos.each do |acesso|
      pdf.start_new_page if pdf.cursor < 40
      pdf.text texto([ I18n.l(acesso.data_hora), acesso.catraca.restaurante.nome, acesso.catraca.identificacao,
                       acesso.aluno.matricula, acesso.modo_validacao, acesso.status,
                       number_to_currency(acesso.tarifa) ].join(" | ")), size: 9
    end

    pdf.number_pages "Página <page> de <total>", at: [ 0, -22 ], align: :right, size: 9
    pdf.render
  end

  private

  def descricao_dos_filtros
    partes = []
    partes << "de #{I18n.l(@relatorio.data_inicial)}" if @relatorio.data_inicial
    partes << "até #{I18n.l(@relatorio.data_final)}" if @relatorio.data_final
    partes << @relatorio.restaurante.nome if @relatorio.restaurante
    partes << @relatorio.catraca.identificacao if @relatorio.catraca
    partes.any? ? partes.join(", ") : "nenhum (todos os acessos)"
  end

  # As fontes padrão do PDF só cobrem Windows-1252 (mesma solução do ExtratoPdf).
  def texto(valor)
    valor.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?")
  end
end
