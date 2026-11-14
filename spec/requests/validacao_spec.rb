require "rails_helper"

RSpec.describe "Validação de acesso na catraca", type: :request do
  let(:restaurante) { criar_restaurante(nome: "RU Darcy Ribeiro") }
  let!(:catraca) { Catraca.create!(numero: "4", piso: 1, online: true, restaurante: restaurante) }
  let!(:cafe) { TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30", tarifa: BigDecimal("2.50")) }
  let!(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30", tarifa: BigDecimal("4.50")) }

  let(:funcionario) { criar_usuario(perfil: :funcionario, saldo: 0) }
  let(:aluno) do
    criar_usuario(perfil: :aluno, saldo: BigDecimal("50.00")).tap do |u|
      u.update!(qr_code: "QR_VALIDO_123")
    end
  end

  def selecionar_catraca_na_sessao(catraca_alvo = catraca)
    post configuracao_de_ponto_path, params: {
      restaurante_id: catraca_alvo.restaurante_id,
      catraca_id: catraca_alvo.id
    }
  end

  before do
    travel_to Time.zone.parse("2026-10-16 12:00:00")
  end

  describe "controle de acesso e painel da catraca" do
    it "bloqueia acesso de usuário com perfil aluno" do
      entrar_como(aluno)
      get validacao_path

      expect(response).to redirect_to(root_path)
    end

    it "exibe a catraca selecionada na sessão no painel Catraca Atual" do
      entrar_como(funcionario)
      selecionar_catraca_na_sessao(catraca)
      get validacao_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Catraca Atual: 4")
      expect(response.body).to include("Leitura Ótica do QR code")
    end

    it "bloqueia a validação se nenhuma catraca estiver selecionada na sessão" do
      entrar_como(funcionario)
      post validacao_path, params: { qr_code: aluno.qr_code }

      expect(response).to redirect_to(validacao_path)
      expect(flash[:status_catraca]).to eq("Erro: Acesso negado.")
      expect(aluno.reload.saldo).to eq(BigDecimal("50.00"))
    end
  end

  describe "processamento de passagem" do
    before do
      entrar_como(funcionario)
      selecionar_catraca_na_sessao(catraca)
    end

    it "libera passagem, debita tarifa do almoço, cria transação e registra histórico" do
      post validacao_path, params: { qr_code: aluno.qr_code }

      expect(response).to redirect_to(validacao_path)
      expect(flash[:status_catraca]).to eq("Liberado")
      expect(aluno.reload.saldo).to eq(BigDecimal("45.50"))

      transacao = aluno.transacoes.last
      expect(transacao).not_to be_nil
      expect(transacao.valor).to eq(BigDecimal("-4.50"))
      expect(transacao.catraca).to eq(catraca)
      expect(transacao.restaurante).to eq(restaurante)
      expect(transacao.metodo).to eq("Comum")

      historico = HistoricoCatraca.where(catraca: catraca, aluno: aluno).last
      expect(historico).not_to be_nil
      expect(historico.status).to eq("Liberado") if historico.respond_to?(:status)
    end

    it "cobra tarifa reduzida no turno do café da manhã" do
      travel_to Time.zone.parse("2026-10-16 08:00:00")
      aluno.update!(saldo: BigDecimal("10.00"))

      post validacao_path, params: { qr_code: aluno.qr_code }

      expect(flash[:status_catraca]).to eq("Liberado")
      expect(aluno.reload.saldo).to eq(BigDecimal("7.50"))
      expect(aluno.transacoes.last.valor).to eq(BigDecimal("-2.50"))
    end

    it "bloqueia passagem, preserva saldo, não cria transação e registra histórico bloqueado quando saldo é insuficiente" do
      aluno.update!(saldo: BigDecimal("2.00"))

      post validacao_path, params: { qr_code: aluno.qr_code }

      expect(response).to redirect_to(validacao_path)
      expect(flash[:status_catraca]).to eq("Bloqueado")
      expect(flash[:mensagem_status]).to match(/saldo insuficiente/i)
      expect(aluno.reload.saldo).to eq(BigDecimal("2.00"))
      expect(aluno.transacoes).to be_empty

      historico = HistoricoCatraca.where(catraca: catraca, aluno: aluno).last
      expect(historico).not_to be_nil
      expect(historico.status).to eq("Bloqueado")
      expect(historico.motivo).to eq("Saldo insuficiente")
      expect(historico.tarifa).to eq(0)
    end

    it "bloqueia passagem quando fora do horário de refeição" do
      travel_to Time.zone.parse("2026-10-16 15:45:00")

      post validacao_path, params: { qr_code: aluno.qr_code }

      expect(flash[:status_catraca]).to eq("Bloqueado")
      expect(flash[:mensagem_status]).to match(/fora do turno de refeição/i)
      expect(aluno.reload.saldo).to eq(BigDecimal("50.00"))
      expect(aluno.transacoes).to be_empty
    end

    it "bloqueia passagem quando QR Code não existe" do
      post validacao_path, params: { qr_code: "QRCODE_INEXISTENTE" }

      expect(response).to redirect_to(validacao_path)
      expect(flash[:status_catraca]).to eq("Bloqueado")
      expect(flash[:mensagem_status]).to match(/QR Code inválido/i)
    end
  end
end
