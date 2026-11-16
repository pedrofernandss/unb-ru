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

  describe "integração com o Terminal de Validação oficial (/terminal-de-validacao)" do
    before do
      entrar_como(funcionario)
      selecionar_catraca_na_sessao(catraca)
    end

    it "valida passagem lendo o QR Code no Modo Comum e exibe nome, refeição e saldo atualizado" do
      get terminal_de_validacao_path
      expect(response).to have_http_status(:ok)

      chave = Nokogiri::HTML(response.body).at_css("input[name='chave']")["value"]

      post terminal_de_validacao_path, params: {
        chave: chave,
        modo: "Comum",
        matricula: aluno.qr_code
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ACESSO LIBERADO")
      expect(response.body).to include(aluno.nome)
      expect(response.body).to include("Almoço")
      expect(aluno.reload.saldo).to eq(BigDecimal("45.50"))
    end

    it "bloqueia no Terminal de Validação quando o QR Code tem saldo insuficiente" do
      aluno.update!(saldo: BigDecimal("2.00"))
      get terminal_de_validacao_path
      chave = Nokogiri::HTML(response.body).at_css("input[name='chave']")["value"]

      post terminal_de_validacao_path, params: {
        chave: chave,
        modo: "Comum",
        matricula: aluno.qr_code
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ACESSO BLOQUEADO")
      expect(response.body).to include("Saldo insuficiente")
      expect(aluno.reload.saldo).to eq(BigDecimal("2.00"))
    end

    it "registra ProcessamentoAcesso bloqueado quando a matrícula ou QR Code não existe" do
      get terminal_de_validacao_path
      chave = Nokogiri::HTML(response.body).at_css("input[name='chave']")["value"]

      expect do
        post terminal_de_validacao_path, params: {
          chave: chave,
          modo: "Comum",
          matricula: "999999999"
        }
      end.to change(ProcessamentoAcesso, :count).by(1)
         .and change(Transacao, :count).by(0)
         .and change(HistoricoCatraca, :count).by(0)

      processamento = ProcessamentoAcesso.last
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ACESSO BLOQUEADO")
      expect(response.body).to include("Aluno não encontrado")
      expect(processamento.liberado).to be(false)
      expect(processamento.matricula).to eq("999999999")
      expect(processamento.motivo).to eq("Aluno não encontrado")
    end

    it "cobra a tarifa reduzida do Café da manhã e grava a transação no Terminal de Validação" do
      travel_to Time.zone.parse("2026-10-16 08:00:00")
      get terminal_de_validacao_path
      chave = Nokogiri::HTML(response.body).at_css("input[name='chave']")["value"]

      expect do
        post terminal_de_validacao_path, params: {
          chave: chave,
          modo: "Comum",
          matricula: aluno.matricula
        }
      end.to change(Transacao, :count).by(1)

      transacao = Transacao.last
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ACESSO LIBERADO")
      expect(response.body).to include("Café da manhã")
      expect(aluno.reload.saldo).to eq(BigDecimal("47.50"))
      expect(transacao.valor).to eq(BigDecimal("-2.50"))
      expect(transacao.tipo).to eq("Café da manhã")
    end
  end
end
