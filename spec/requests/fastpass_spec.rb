require "rails_helper"

RSpec.describe "Validação FastPass", type: :request do
  let(:funcionario) { criar_usuario(perfil: :funcionario) }
  let(:aluno) { criar_usuario(saldo: 18) }
  let(:restaurante) { criar_restaurante }
  let(:catraca) { restaurante.catracas.create!(numero: 4, piso: 2, online: true) }
  let(:turno) { TipoRefeicao.find_or_create_by!(nome: "Almoço") { |t| t.hora_inicio = "11:00"; t.hora_fim = "14:00" } }
  let(:janela) { turno.time_frames.create!(inicio: "12:15", fim: "12:30") }
  let!(:inscricao) { InscricaoFastpass.create!(aluno: aluno, time_frame: janela, data: Date.new(2026, 11, 6), status: :contemplado) }

  before do
    travel_to Time.zone.local(2026, 11, 6, 12, 18, 22)
    @comandos = []
    dispositivo = instance_double(Catracas::Simulada, disponivel?: true)
    allow(dispositivo).to receive(:enviar) do |**comando|
      @comandos << comando
      true
    end
    Rails.configuration.x.dispositivo_catraca = dispositivo
    entrar_como(funcionario)
    post configuracao_de_ponto_path, params: { restaurante_id: restaurante.id, catraca_id: catraca.id }
    get terminal_de_validacao_path
    @chave = Nokogiri::HTML(response.body).at_css('input[name="chave"]')["value"]
  end
  after { Rails.configuration.x.dispositivo_catraca = nil }

  def validar(**extras)
    post terminal_de_validacao_path, params: { matricula: aluno.matricula, chave: @chave, modo: "FastPass" }.merge(extras)
  end

  it "usa horário do servidor e faz débito, histórico e comando pelo fluxo HTTP" do
    validar(lido_em: "2026-11-07 18:00", catraca_id: 9999, valor: "0.01")
    expect(response.body).to include("ACESSO LIBERADO", "13,50")
    expect(aluno.reload.saldo).to eq(13.50)
    transacao = aluno.transacoes.sole
    expect(transacao.valor).to eq(-4.50)
    expect(transacao.catraca).to eq(catraca)
    expect(transacao.restaurante).to eq(restaurante)
    expect(transacao.metodo).to eq("FastPass")
    expect(catraca.historicos_catraca.count).to eq(1)
    expect(@comandos.map { |c| c[:comando] }).to eq([ :liberar ])
  end

  { "12:14:59" => false, "12:15:00" => true, "12:30:00" => true, "12:30:01" => false }.each do |hora, liberado|
    it "#{liberado ? 'permite' : 'bloqueia'} às #{hora}, com limites explícitos" do
      travel_to Time.zone.parse("2026-11-06 #{hora}")
      validar
      expect(response.body).to include(liberado ? "ACESSO LIBERADO" : "ACESSO BLOQUEADO")
      expect(aluno.reload.saldo).to eq(liberado ? 13.50 : 18)
      expect(@comandos.last[:comando]).to eq(liberado ? :liberar : :bloquear)
    end
  end

  it "não aplica a tolerância configurada para o sorteio/turno" do
    turno.update!(tolerancia_minutos: 5)
    travel_to Time.zone.local(2026, 11, 6, 12, 30, 1)
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "Fora do time-frame")
    expect(aluno.reload.saldo).to eq(18)
  end

  it "recusa saldo insuficiente sem débito" do
    aluno.update!(saldo: 2)
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "Saldo insuficiente")
    expect(aluno.reload.saldo).to eq(2)
    expect(aluno.transacoes).to be_empty
  end

  context "com um turno de tarifa menor" do
    let!(:cafe) { TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30", tarifa: "2.50") }

    before do
      inscricao.update!(time_frame: cafe.time_frames.create!(inicio: "08:00", fim: "08:15"))
      travel_to Time.zone.local(2026, 11, 6, 8, 5)
    end

    it "debita a tarifa do turno da leitura, e não um valor único" do
      validar

      expect(response.body).to include("ACESSO LIBERADO")
      expect(aluno.reload.saldo).to eq(15.50)
      expect(aluno.transacoes.sole).to have_attributes(valor: -2.50, tipo: "Café da manhã")
    end

    it "libera com saldo que cobre o café da manhã mas não cobriria o almoço" do
      aluno.update!(saldo: 3)

      validar

      expect(response.body).to include("ACESSO LIBERADO")
      expect(aluno.reload.saldo).to eq(0.50)
    end
  end

  it "recusa inscrição de outra data, mesmo no mesmo horário" do
    inscricao.update!(data: Date.new(2026, 11, 5))
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "sem contemplação")
    expect(aluno.reload.saldo).to eq(18)
  end

  it "trata ausência de contemplação e janela apagada de forma controlada" do
    inscricao.update!(status: :inscrito)
    validar
    expect(response.body).to include("ACESSO BLOQUEADO")
    janela.destroy!
    get terminal_de_validacao_path
    @chave = Nokogiri::HTML(response.body).at_css('input[name="chave"]')["value"]
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "sem contemplação")
    expect(aluno.reload.saldo).to eq(18)
  end

  it "deduplica o mesmo evento sem repetir débito, histórico ou comando" do
    2.times { validar }
    expect(aluno.reload.saldo).to eq(13.50)
    expect(aluno.transacoes.count).to eq(1)
    expect(catraca.historicos_catraca.count).to eq(1)
    expect(@comandos.size).to eq(1)
  end

  it "não inventa restrição de uma refeição por dia para eventos distintos" do
    validar
    @chave = Nokogiri::HTML(response.body).at_css('input[name="chave"]')["value"]
    validar
    expect(aluno.reload.saldo).to eq(9)
    expect(aluno.transacoes.count).to eq(2)
  end

  it "rejeita reutilização de chave com outra matrícula" do
    validar
    validar(matricula: criar_usuario.matricula)
    expect(response).to have_http_status(:conflict)
    expect(aluno.transacoes.count).to eq(1)
  end

  it "recusa outra unidade quando a inscrição restringe restaurante" do
    inscricao.update!(restaurante: criar_restaurante)
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "outro restaurante")
    expect(aluno.reload.saldo).to eq(18)
  end

  it "rejeita chave de outra catraca após trocar de ponto" do
    segunda = restaurante.catracas.create!(numero: 5, piso: 1, online: true)
    post configuracao_de_ponto_path, params: { restaurante_id: restaurante.id, catraca_id: segunda.id }
    validar
    expect(response).to have_http_status(:unprocessable_entity)
    expect(aluno.reload.saldo).to eq(18)
  end

  it "trata aluno desconhecido sem liberar a catraca" do
    validar(matricula: "000000000")
    expect(response.body).to include("ACESSO BLOQUEADO", "Aluno não encontrado")
    expect(@comandos.last[:comando]).to eq(:bloquear)
  end

  it "compartilha o mecanismo financeiro com o modo comum" do
    inscricao.destroy!
    validar(modo: "Comum")
    expect(response.body).to include("ACESSO LIBERADO")
    expect(aluno.transacoes.sole.metodo).to eq("Comum")
    expect(aluno.reload.saldo).to eq(13.50)
  end

  it "não debita se o dispositivo não estiver configurado" do
    Rails.configuration.x.dispositivo_catraca = Catracas::Indisponivel.new
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "indisponível")
    expect(aluno.reload.saldo).to eq(18)
    expect(aluno.transacoes).to be_empty
  end

  it "repete somente a entrega pendente, sem repetir o débito" do
    dispositivo = Rails.configuration.x.dispositivo_catraca
    allow(dispositivo).to receive(:enviar).and_return(false, true)
    validar
    expect(response.body).to include("ACESSO BLOQUEADO", "Comando pendente")
    validar
    expect(response.body).to include("ACESSO LIBERADO")
    expect(aluno.reload.saldo).to eq(13.50)
    expect(aluno.transacoes.count).to eq(1)
    expect(dispositivo).to have_received(:enviar).twice
  end

  it "desfaz débito e evento se a gravação financeira falhar" do
    allow_any_instance_of(Transacao).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
    validar
    expect(response).to have_http_status(422)
    expect(aluno.reload.saldo).to eq(18)
    expect(ProcessamentoAcesso.count).to eq(0)
    expect(catraca.historicos_catraca).to be_empty
    expect(@comandos).to be_empty
  end
end
