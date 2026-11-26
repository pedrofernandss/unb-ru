require "rails_helper"

RSpec.describe "Turnos e time-frames", type: :request do
  let!(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:00") }
  let!(:jantar) { TipoRefeicao.create!(nome: "Jantar", hora_inicio: "17:00", hora_fim: "19:00") }

  def configurar(turno, granularidade:, tolerancia: "0")
    patch configurar_time_frames_admin_turnos_path,
          params: { configuracao: { id: turno.id, granularidade_minutos: granularidade, tolerancia_minutos: tolerancia } }
  end

  context "como administrador" do
    before { entrar_como(criar_usuario(perfil: :administrador)) }

    it "lista os turnos com os horários" do
      get admin_turnos_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Almoço", "11:00 - 14:00", "Jantar", "17:00 - 19:00")
    end

    it "abre o formulário de edição na própria lista" do
      get edit_admin_turno_path(almoco)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Editar horários do Almoço")
    end

    it "avisa na edição quando mudar o horário apaga janelas e inscrições" do
      get edit_admin_turno_path(almoco)
      expect(response.body).not_to include("Mudar o horário apaga")

      almoco.configurar_time_frames(granularidade: "60", tolerancia: "0")
      criar_usuario.inscricoes_fastpass.create!(time_frame: almoco.time_frames.first, data: Date.current)
      get edit_admin_turno_path(almoco)
      expect(response.body).to include("Mudar o horário apaga 3 janelas do FastPass deste turno e 1 inscrição de alunos nelas")
    end

    it "responde 404 para turno inexistente" do
      get edit_admin_turno_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end

    it "atualiza o horário de um turno" do
      patch admin_turno_path(almoco), params: { tipo_refeicao: { hora_inicio: "11:30", hora_fim: "14:30" } }
      expect(response).to redirect_to(admin_turnos_path)
      expect(flash[:notice]).to eq("Turno atualizado com sucesso")
      expect(almoco.reload).to have_attributes(hora_inicio_formatada: "11:30", hora_fim_formatada: "14:30")
    end

    it "recusa horário que se sobrepõe a outro turno e mantém o salvo" do
      patch admin_turno_path(almoco), params: { tipo_refeicao: { hora_inicio: "16:00", hora_fim: "18:00" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Não foi possível atualizar o turno")
      expect(response.body).to include("O horário do Almoço se sobrepõe ao turno Jantar")
      expect(almoco.reload).to have_attributes(hora_inicio_formatada: "11:00", hora_fim_formatada: "14:00")
    end

    it "recusa horário final antes do inicial" do
      patch admin_turno_path(almoco), params: { tipo_refeicao: { hora_inicio: "14:00", hora_fim: "11:00" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("O horário final deve ser posterior ao inicial")
    end

    it "gera os time-frames do turno escolhido" do
      configurar(almoco, granularidade: "30", tolerancia: "5")
      expect(response).to redirect_to(admin_turnos_path)
      expect(flash[:notice]).to eq("Time-frames gerados com sucesso")
      expect(almoco.time_frames.count).to eq(6)
      expect(almoco.reload.tolerancia_minutos).to eq(5)
      expect(jantar.time_frames).to be_empty
    end

    it "recusa granularidade que não divide o turno" do
      configurar(almoco, granularidade: "25")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Não foi possível gerar os time-frames")
      expect(response.body).to include("A granularidade deve dividir a duração do turno (180 min)")
      expect(almoco.time_frames).to be_empty
    end

    it "recusa granularidade que não é número" do
      configurar(almoco, granularidade: "abc")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("A granularidade deve ser um número")
    end

    it "avisa antes de reconfigurar quando o turno já tem janelas" do
      get admin_turnos_path
      expect(response.body).not_to include("Se a granularidade mudar")

      configurar(almoco, granularidade: "30")
      get admin_turnos_path
      expect(response.body).to include("Se a granularidade mudar", "6 janelas de 30 min")
    end
  end

  %i[aluno funcionario].each do |perfil|
    context "como #{perfil}" do
      before { entrar_como(criar_usuario(perfil: perfil)) }

      it "não acessa a gestão nem altera turnos" do
        get admin_turnos_path
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to eq("Acesso restrito a administradores")

        patch admin_turno_path(almoco), params: { tipo_refeicao: { hora_inicio: "11:30", hora_fim: "14:30" } }
        configurar(almoco, granularidade: "30")
        expect(almoco.reload).to have_attributes(hora_inicio_formatada: "11:00", granularidade_minutos: nil)
        expect(almoco.time_frames).to be_empty
      end
    end
  end

  it "exige login" do
    get admin_turnos_path
    expect(response).to redirect_to(login_path)
  end
end
