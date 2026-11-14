require "rails_helper"
require "pdf/reader"

RSpec.describe "Recargas", type: :request do
  let(:aluno) { criar_usuario(saldo: 18) }
  before { entrar_como(aluno) }
  after { Rails.configuration.x.provedor_pagamento = nil }

  def iniciar(quantidade: "5", metodo: "PIX", **extras)
    get nova_recarga_path
    chave = Nokogiri::HTML(response.body).at_css('input[name="chave"]')["value"]
    post nova_recarga_path, params: { chave: chave, quantidade: quantidade, metodo: metodo }.merge(extras)
    aluno.recargas.order(:id).last
  end

  %w[PIX Cartão].each do |metodo|
    it "aprova #{metodo} pelo fluxo HTTP e aparece no extrato/PDF uma única vez" do
      recarga = iniciar(metodo: metodo, valor: "0.01", aluno_id: criar_usuario.id)
      expect(aluno.reload.saldo).to eq(18)
      expect(aluno.transacoes).to be_empty
      expect(recarga.valor).to eq(22.50)
      2.times { post confirmar_recarga_path(recarga) }
      follow_redirect!
      expect(response.body).to include("Recarga realizada com sucesso", "aprovada")
      expect(aluno.reload.saldo).to eq(40.50)
      expect(aluno.transacoes.count).to eq(1)
      get exportar_extrato_path
      texto = PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join
      expect(texto).to include("Recarga de Saldo", metodo, "22,50")
    end
  end

  [ "0", "51", "1.5", "-1", "abc", "" ].each do |quantidade|
    it "recusa quantidade inválida #{quantidade.inspect} no servidor" do
      iniciar(quantidade: quantidade)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Informe uma quantidade entre 1 e 50 refeições")
      expect(aluno.reload.saldo).to eq(18)
      expect(aluno.recargas).to be_empty
    end
  end

  [ 1, 50 ].each do |quantidade|
    it "aceita quantidade personalizada no limite #{quantidade}" do
      recarga = iniciar(outra_quantidade: quantidade.to_s)
      expect(recarga.quantidade).to eq(quantidade)
      expect(recarga.valor).to eq(quantidade * TarifaRefeicao.referencia)
    end
  end

  it "recusa pagamento sem gerar crédito e não tenta cobrar novamente" do
    provedor = instance_double(Pagamentos::Simulado)
    allow(provedor).to receive(:cobrar).and_return(:recusado)
    Rails.configuration.x.provedor_pagamento = provedor
    recarga = iniciar
    2.times { post confirmar_recarga_path(recarga) }
    follow_redirect!
    expect(response.body).to include("Não foi possível concluir o pagamento")
    expect(provedor).to have_received(:cobrar).once
    expect(aluno.reload.saldo).to eq(18)
    expect(aluno.transacoes).to be_empty
  end

  it "cobra o pacote pela maior tarifa vigente e mostra o preço de cada turno" do
    TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30", tarifa: "2.50")
    TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30", tarifa: "6.00")

    get nova_recarga_path
    expect(response.body).to include("Café da manhã", "R$ 2,50", "Almoço", "R$ 6,00")

    recarga = iniciar(quantidade: "5")
    expect(recarga.valor).to eq(30.00)
  end

  it "deduplica o envio inicial da mesma operação" do
    get nova_recarga_path
    chave = Nokogiri::HTML(response.body).at_css('input[name="chave"]')["value"]
    2.times { post nova_recarga_path, params: { chave: chave, quantidade: "5", metodo: "PIX" } }
    expect(aluno.recargas.count).to eq(1)
  end

  it "não permite consultar ou confirmar operação de outro aluno" do
    recarga = iniciar
    entrar_como(criar_usuario)
    get recarga_path(recarga)
    expect(response).to have_http_status(:not_found)
    post confirmar_recarga_path(recarga)
    expect(response).to have_http_status(:not_found)
    expect(aluno.reload.saldo).to eq(18)
  end

  it "exige perfil de aluno e chave válida" do
    post nova_recarga_path, params: { chave: "forjada", quantidade: 5, metodo: "PIX" }
    expect(response).to have_http_status(:unprocessable_entity)
    entrar_como(criar_usuario(perfil: :funcionario))
    get nova_recarga_path
    expect(response).to have_http_status(:forbidden)
  end

  it "desfaz saldo e confirmação se o lançamento falhar" do
    recarga = iniciar
    allow_any_instance_of(Transacao).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
    expect { recarga.confirmar! }.to raise_error(ActiveRecord::RecordInvalid)
    expect(aluno.reload.saldo).to eq(18)
    expect(recarga.reload).to be_pendente
    expect(aluno.transacoes).to be_empty
  end
end
