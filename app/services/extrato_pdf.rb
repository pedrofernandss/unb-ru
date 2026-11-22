# Usa a mesma consulta das linhas da tela, sem offset/limit nem indicadores do período.
class ExtratoPdf
  include DocumentoPdf

  def initialize(extrato)
    @extrato = extrato
  end

  private

  def escrever_conteudo
    cabecalho
    @extrato.filtradas.recentes.includes(:restaurante, catraca: :restaurante).each do |transacao|
      escrever_transacao(transacao)
    end
  end

  def cabecalho
    escrever "Extrato e Histórico de Refeições", size: 18, style: :bold
    @pdf.move_down 12
    escrever @extrato.aluno.nome, size: 11
    escrever periodo, size: 10
    escrever_filtros
    @pdf.move_down 16
  end

  def periodo = "#{data(@extrato.data_inicial)} a #{data(@extrato.data_final)}"

  def escrever_filtros
    escrever "Filtros: #{filtros.join(' / ')}", size: 10 if filtros.any?
  end

  def filtros
    @filtros ||= [ @extrato.tipo, @extrato.metodo, restaurante_filtrado&.nome ].compact
  end

  def restaurante_filtrado = @extrato.restaurantes_disponiveis.find_by(id: @extrato.restaurante_id)

  def escrever_transacao(transacao)
    garantir_espaco(78)
    escrever "#{data_hora(transacao)} | #{transacao.tipo}", size: 11, style: :bold
    escrever "#{transacao.local} | #{metodo(transacao)}", size: 10
    escrever number_to_currency(transacao.valor), size: 11
    separador
  end

  def separador
    @pdf.move_down 6
    @pdf.stroke_horizontal_rule
    @pdf.move_down 10
  end

  def metodo(transacao) = transacao.metodo.presence || "Método não informado"
  def data(valor) = valor.strftime("%d/%m/%Y")
  def data_hora(transacao) = transacao.data_hora.in_time_zone.strftime("%d/%m/%Y %H:%M")
end
