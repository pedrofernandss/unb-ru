# Documento de auditoria do Relatório Global (#12): totais, consolidações e todos os acessos dos filtros.
class RelatorioGlobalPdf
  include DocumentoPdf

  def initialize(relatorio)
    @relatorio = relatorio
  end

  private

  def escrever_conteudo
    cabecalho
    indicadores
    secao("Consolidação por restaurante", @relatorio.consolidacao) { |linha| linha_restaurante(linha) }
    secao("Consolidação por catraca", @relatorio.consolidacao_por_catraca) { |linha| linha_catraca(linha) }
    lista_de_acessos
  end

  def cabecalho
    escrever "Relatório Global de Operação", size: 18, style: :bold
    escrever "Emitido em #{I18n.l(Time.current)}", size: 9
    @pdf.move_down 8
    escrever "Filtros: #{descricao_dos_filtros}", size: 10
    @pdf.move_down 12
  end

  def indicadores
    escrever "Refeições servidas: #{@relatorio.refeicoes_servidas} de #{@relatorio.total_acessos} acessos", size: 11
    escrever "Arrecadação global: #{number_to_currency(@relatorio.arrecadacao)}", size: 11, style: :bold
    escrever "Acessos via FastPass: #{@relatorio.acessos_fastpass}", size: 11
    @pdf.move_down 12
  end

  # Título seguido de uma linha por item; o bloco formata cada linha.
  def secao(titulo, linhas)
    escrever titulo, size: 13, style: :bold
    linhas.each { |linha| escrever yield(linha), size: 10 }
    @pdf.move_down 12
  end

  def linha_restaurante(linha) = "#{linha.restaurante.nome}: #{totais(linha)}"

  def linha_catraca(linha)
    catraca = linha.catraca
    "#{catraca.restaurante.nome}, #{catraca.identificacao} (piso #{catraca.piso}): #{totais(linha)}"
  end

  # Resumo igual nas duas consolidações.
  def totais(linha)
    "#{linha.liberados} liberados, #{linha.acessos - linha.liberados} bloqueados, " \
      "#{linha.fastpass} FastPass, #{number_to_currency(linha.arrecadacao)}"
  end

  def lista_de_acessos
    escrever "Acessos", size: 13, style: :bold
    @pdf.move_down 4
    @relatorio.acessos.each do |acesso|
      garantir_espaco(40)
      escrever linha_acesso(acesso), size: 9
    end
  end

  def linha_acesso(acesso)
    [ I18n.l(acesso.data_hora), *local_do_acesso(acesso), acesso.aluno.matricula,
      acesso.modo_validacao, acesso.status, number_to_currency(acesso.tarifa) ].join(" | ")
  end

  def local_do_acesso(acesso) = [ acesso.catraca.restaurante.nome, acesso.catraca.identificacao ]

  def descricao_dos_filtros
    partes = [ data_do_filtro("de", @relatorio.data_inicial), data_do_filtro("até", @relatorio.data_final),
               @relatorio.restaurante&.nome, @relatorio.catraca&.identificacao ].compact
    partes.any? ? partes.join(", ") : "nenhum (todos os acessos)"
  end

  def data_do_filtro(prefixo, data) = ("#{prefixo} #{I18n.l(data)}" if data)
end
