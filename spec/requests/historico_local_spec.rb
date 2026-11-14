# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Histórico Local", type: :request do
  let(:funcionario) { criar_usuario(perfil: :funcionario) }
  let(:restaurante) { criar_restaurante }
  let(:catraca_ativa) { restaurante.catracas.create!(numero: 4, piso: 2, online: true) }
  let(:outra_catraca) { restaurante.catracas.create!(numero: 2, piso: 1, online: true) }

  def vincular(ponto = catraca_ativa)
    post configuracao_de_ponto_path, params: {
      restaurante_id: ponto.restaurante_id,
      catraca_id: ponto.id
    }
  end

  describe "GET /historico-local" do
    context "quando o funcionário não selecionou uma catraca na sessão" do
      it "redireciona para a configuração de ponto de acesso" do
        entrar_como(funcionario)

        get historico_local_path

        expect(response).to redirect_to(configuracao_de_ponto_path)
      end
    end

    context "quando o funcionário está operando uma catraca" do
      before do
        entrar_como(funcionario)
        vincular(catraca_ativa)
      end

      it "exibe apenas os registros da catraca ativa incluindo tarifa, status e motivo" do
        aluno = criar_usuario(perfil: :aluno)
        outro_aluno = criar_usuario(perfil: :aluno)

        catraca_ativa.historicos_catraca.create!(
          aluno: aluno,
          data_hora: Time.zone.parse("2026-11-14 12:10:00"),
          modo_validacao: "Comum",
          tarifa: BigDecimal("4.50"),
          status: "Liberado",
          motivo: "Validação concluída"
        )

        catraca_ativa.historicos_catraca.create!(
          aluno: aluno,
          data_hora: Time.zone.parse("2026-11-14 12:12:00"),
          modo_validacao: "Comum",
          tarifa: BigDecimal("0.00"),
          status: "Bloqueado",
          motivo: "Saldo insuficiente"
        )

        outra_catraca.historicos_catraca.create!(
          aluno: outro_aluno,
          data_hora: Time.zone.parse("2026-11-14 12:15:00"),
          modo_validacao: "FastPass",
          tarifa: BigDecimal("4.50"),
          status: "Liberado",
          motivo: "Acesso outra catraca"
        )

        get historico_local_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Horário", "Matrícula (Discente)", "Modo de Validação", "Tarifa", "Status da Catraca", "Motivo")
        expect(response.body).to include(aluno.matricula, "R$4,50", "Liberado", "Validação concluída")
        expect(response.body).to include("R$0,00", "Bloqueado", "Saldo insuficiente")
        expect(response.body).not_to include(outro_aluno.matricula, "Acesso outra catraca")
      end
    end

    context "quando um aluno tenta acessar o histórico local" do
      it "bloqueia o acesso e redireciona para a home do aluno" do
        aluno = criar_usuario(perfil: :aluno)
        entrar_como(aluno)

        get historico_local_path

        expect(response).to redirect_to(home_path)
      end
    end
  end
end
