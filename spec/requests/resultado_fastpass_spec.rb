require "rails_helper"

RSpec.describe "Resultado do sorteio do FastPass", type: :request do
  let(:aluno) { criar_usuario }
  let(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "12:00", hora_fim: "14:00") }
  let(:janela) { almoco.time_frames.create!(inicio: "12:00", fim: "12:15") }
  let!(:inscricao) { aluno.inscricoes_fastpass.create!(time_frame: janela, data: Date.current) }

  def hoje_as(hora, minuto) = Time.zone.today.in_time_zone.change(hour: hora, min: minuto)

  before { entrar_como aluno }

  it "antes da divulgação mostra o aviso e permite cancelar" do
    travel_to(hoje_as(10, 30)) { get fastpass_path }

    assert_select "#painel-resultado-fastpass", count: 0
    assert_select ".secao-turno", text: /O Sorteio do FastPass ainda não aconteceu/
    assert_select "button", text: "Cancelar inscrição"
  end

  it "mostra quem ganhou o FastPass" do
    inscricao.contemplado!
    travel_to(hoje_as(11, 30)) { get fastpass_path }

    assert_select "#painel-resultado-fastpass", text: /Resultado do FastPass/
    assert_select "#painel-resultado-fastpass", text: /Você ganhou o FastPass!/
  end

  it "mostra quem não ganhou o FastPass" do
    inscricao.nao_contemplado!
    travel_to(hoje_as(11, 30)) { get fastpass_path }

    assert_select "#painel-resultado-fastpass", text: /Você não ganhou o FastPass. Boa sorte na próxima vez./
  end

  it "na última hora sem sorteio avisa que está processando e esconde o cancelar" do
    travel_to(hoje_as(11, 30)) { get fastpass_path }

    assert_select "#painel-resultado-fastpass", text: /ainda está sendo processado/
    assert_select "button", text: "Cancelar inscrição", count: 0
  end

  it "sem inscrição, mostra o formulário antes e as inscrições encerradas na última hora" do
    inscricao.destroy!

    travel_to(hoje_as(10, 30)) { get fastpass_path }
    assert_select "button", text: "Confirmar Inscrição"

    travel_to(hoje_as(11, 30)) { get fastpass_path }
    assert_select ".secao-turno", text: /As inscrições para o Almoço de hoje já foram encerradas/
    assert_select "button", text: "Confirmar Inscrição", count: 0
  end
end
