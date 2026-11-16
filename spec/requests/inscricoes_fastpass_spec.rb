require "rails_helper"

RSpec.describe "Inscrição no FastPass", type: :request do
  let(:aluno) { criar_usuario }
  let(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:00") }
  let!(:janela) { almoco.time_frames.create!(inicio: "12:00", fim: "12:15") }
  let!(:outra_janela) { almoco.time_frames.create!(inicio: "12:15", fim: "12:30") }

  def hoje_as(hora, minuto) = Time.zone.today.in_time_zone.change(hour: hora, min: minuto)

  it "exige login" do
    expect { post fastpass_inscricoes_path, params: { time_frame_id: janela.id } }
      .not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(login_path)
  end

  it "não deixa o funcionário ver nem se inscrever no FastPass" do
    entrar_como criar_usuario(perfil: :funcionario)

    get fastpass_path
    expect(response).to redirect_to(home_path)

    expect { post fastpass_inscricoes_path, params: { time_frame_id: janela.id } }
      .not_to change(InscricaoFastpass, :count)
    expect(response).to redirect_to(home_path)
    expect(flash[:alert]).to eq("O FastPass é exclusivo para alunos")
  end

  it "inscreve o aluno com status inscrito" do
    entrar_como aluno

    expect { travel_to(hoje_as(9, 30)) { post fastpass_inscricoes_path, params: { time_frame_id: janela.id } } }
      .to change(InscricaoFastpass, :count).by(1)

    inscricao = aluno.inscricoes_fastpass.last
    expect(response).to redirect_to(fastpass_path)
    expect(flash[:notice]).to eq("Inscrição no sorteio realizada com sucesso")
    expect(inscricao.time_frame).to eq(janela)
    expect(inscricao.data).to eq(Date.current)
    expect(inscricao).to be_inscrito
  end

  it "pede para escolher um horário quando nenhuma janela é enviada" do
    entrar_como aluno

    expect { post fastpass_inscricoes_path, params: { time_frame_id: "" } }
      .not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to eq("Escolha um horário")
  end

  it "recusa segunda inscrição no mesmo turno" do
    entrar_como aluno
    aluno.inscricoes_fastpass.create!(time_frame: janela, data: Date.current)

    expect { travel_to(hoje_as(9, 30)) { post fastpass_inscricoes_path, params: { time_frame_id: outra_janela.id } } }
      .not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to eq("Você já possui uma inscrição para o Almoço. Cancele a atual para alterar o horário.")
  end

  it "não inscreve na última hora antes do turno, quando o resultado já saiu" do
    entrar_como aluno

    expect { travel_to(hoje_as(10, 30)) { post fastpass_inscricoes_path, params: { time_frame_id: janela.id } } }
      .not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to eq("As inscrições para o Almoço de hoje já foram encerradas")
  end

  # O Almoço começa às 11:00 e o resultado sai 1 hora antes.
  it "cancela a própria inscrição antes do resultado" do
    entrar_como aluno
    inscricao = aluno.inscricoes_fastpass.create!(time_frame: janela, data: Date.current)

    expect { travel_to(hoje_as(9, 30)) { delete fastpass_inscricao_path(inscricao) } }
      .to change(InscricaoFastpass, :count).by(-1)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:notice]).to eq("Inscrição cancelada")
  end

  it "não cancela na última hora antes do turno, mesmo sem o botão na tela" do
    entrar_como aluno
    inscricao = aluno.inscricoes_fastpass.create!(time_frame: janela, data: Date.current)

    expect { travel_to(hoje_as(10, 30)) { delete fastpass_inscricao_path(inscricao) } }
      .not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to include("sorteio já foi realizado")
  end

  it "não cancela a inscrição de outro aluno" do
    entrar_como aluno
    inscricao = criar_usuario.inscricoes_fastpass.create!(time_frame: janela, data: Date.current)

    expect { delete fastpass_inscricao_path(inscricao) }.not_to change(InscricaoFastpass, :count)

    expect(response).to have_http_status(:not_found)
  end

  it "não cancela inscrição já contemplada no sorteio" do
    entrar_como aluno
    inscricao = aluno.inscricoes_fastpass.create!(time_frame: janela, data: Date.current, status: :contemplado)

    expect { delete fastpass_inscricao_path(inscricao) }.not_to change(InscricaoFastpass, :count)

    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to include("sorteio já foi realizado")
    expect(inscricao.reload).to be_contemplado
  end
end
