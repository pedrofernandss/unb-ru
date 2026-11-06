require "rails_helper"
require "pdf/reader"

RSpec.describe "Exportação do extrato", type: :request do
  let(:aluno) { criar_usuario }
  let(:restaurante) { criar_restaurante(nome: "Restaurante Brasília") }
  let(:filtros) { { data_inicial: "2026-11-01", data_final: "2026-11-30" } }

  def lancamento(usuario = aluno, **atributos)
    usuario.transacoes.create!({ restaurante: restaurante, data_hora: Time.zone.parse("2026-11-06 12:20"),
                                tipo: "Almoço", metodo: "FastPass", valor: -4.50 }.merge(atributos))
  end

  it "exporta conteúdo real, acentos e todos os registros em múltiplas páginas" do
    65.times { |i| lancamento(tipo: "Refeição #{i.to_s.rjust(3, '0')}") }
    lancamento(criar_usuario, tipo: "SEGREDO OUTRO ALUNO")
    entrar_como(aluno)
    get exportar_extrato_path, params: filtros.merge(pagina: 2)
    expect(response.media_type).to eq("application/pdf")
    expect(response.headers["Content-Disposition"]).to include("extrato-refeicoes.pdf")
    pdf = PDF::Reader.new(StringIO.new(response.body))
    texto = pdf.pages.map(&:text).join("\n")
    expect(pdf.page_count).to be > 1
    expect(texto).to include("Extrato e Histórico de Refeições", "Restaurante Brasília", "Refeição 000", "Refeição 064")
    expect(texto.scan(/Refeição \d{3}/).size).to eq(65)
    expect(texto).not_to include("SEGREDO")
  end

  it "combina filtros de data, tipo, restaurante e método sem incluir totais diferentes" do
    lancamento
    lancamento(tipo: "Jantar")
    lancamento(metodo: "Comum")
    lancamento(restaurante: criar_restaurante(nome: "Outro RU"))
    lancamento(data_hora: Time.zone.parse("2026-10-31 23:59"))
    entrar_como(aluno)
    get exportar_extrato_path, params: filtros.merge(tipo: "Almoço", restaurante_id: restaurante.id, metodo: "FastPass")
    texto = PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join
    expect(texto.scan("R$ -4,50").size + texto.scan("-R$ 4,50").size).to eq(1)
    expect(texto).not_to include("Jantar", "Outro RU", "Comum", "Total gasto")
  end

  it "preserva filtros no link e na resposta sem lançamentos" do
    entrar_como(aluno)
    get extrato_path, params: filtros.merge(metodo: "PIX")
    expect(response.body).to include("extrato/exportar?", "metodo=PIX")
    get exportar_extrato_path, params: filtros.merge(metodo: "PIX")
    expect(response).to redirect_to(extrato_path(filtros.merge(metodo: "PIX")))
    follow_redirect!
    expect(response.body).to include("Não há lançamentos no período selecionado")
    expect(response.media_type).not_to eq("application/pdf")
  end

  it "exige autenticação" do
    get exportar_extrato_path
    expect(response).to redirect_to(login_path)
  end
end
