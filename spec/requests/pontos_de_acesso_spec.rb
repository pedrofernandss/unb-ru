require "rails_helper"

RSpec.describe "Ponto de acesso", type: :request do
  let(:funcionario) { criar_usuario(perfil: :funcionario) }
  let(:restaurante) { criar_restaurante }
  let(:catraca) { restaurante.catracas.create!(numero: 4, piso: 2, online: true) }
  before { entrar_como(funcionario) }

  def vincular(ponto = catraca)
    post configuracao_de_ponto_path, params: { restaurante_id: ponto.restaurante_id, catraca_id: ponto.id }
  end

  it "vincula a sessão e limita terminal/histórico à catraca escolhida" do
    aluno = criar_usuario
    outro = criar_usuario
    catraca.historicos_catraca.create!(aluno: aluno, data_hora: Time.current)
    restaurante.catracas.create!(numero: 5, piso: 2, online: true).historicos_catraca.create!(aluno: outro, data_hora: Time.current)
    vincular
    expect(response).to redirect_to(terminal_de_validacao_path)
    follow_redirect!
    expect(response.body).to include("Catraca 04", "Piso 2", aluno.matricula)
    expect(response.body).not_to include(outro.matricula)
    get historico_local_path
    expect(response.body).to include(aluno.matricula)
    expect(response.body).not_to include(outro.matricula)
    expect(catraca.reload.funcionario_id).to be_nil
  end

  it "rejeita ausência de seleção e combinação de outro restaurante" do
    post configuracao_de_ponto_path
    expect(response).to have_http_status(:unprocessable_entity)
    post configuracao_de_ponto_path, params: { restaurante_id: criar_restaurante.id, catraca_id: catraca.id }
    expect(response).to have_http_status(:unprocessable_entity)
    get terminal_de_validacao_path
    expect(response).to redirect_to(configuracao_de_ponto_path)
  end

  it "rejeita catraca offline e invalida vínculo quando ela fica offline" do
    vincular
    catraca.update!(online: false)
    get terminal_de_validacao_path
    expect(response).to redirect_to(configuracao_de_ponto_path)
    vincular
    expect(response.body).to include("Catraca 04 está offline e não pode ser operada")
  end

  it "troca o ponto sem alterar o responsável cadastral e limpa no logout" do
    vincular
    segunda = restaurante.catracas.create!(numero: 2, piso: 1, online: true)
    vincular(segunda)
    follow_redirect!
    expect(response.body).to include("Catraca 02")
    delete logout_path
    entrar_como(funcionario)
    get terminal_de_validacao_path
    expect(response).to redirect_to(configuracao_de_ponto_path)
  end

  it "mantém sessões independentes para o mesmo funcionário" do
    vincular
    outra_sessao = ActionDispatch::Integration::Session.new(Rails.application)
    outra_sessao.post login_path, params: { matricula: funcionario.matricula, senha: "senha123" }
    outra_sessao.get terminal_de_validacao_path
    expect(outra_sessao.response.status).to eq(302)
    expect(URI(outra_sessao.response.location).path).to eq(configuracao_de_ponto_path)
    get terminal_de_validacao_path
    expect(response).to have_http_status(:ok)
  end

  it "protege GET e POST por perfil" do
    entrar_como(criar_usuario)
    get configuracao_de_ponto_path
    expect(response).to redirect_to(home_path)
    vincular
    expect(response).to redirect_to(home_path)
    get terminal_de_validacao_path
    expect(response).to redirect_to(home_path)
    get historico_local_path
    expect(response).to redirect_to(home_path)
  end
end
