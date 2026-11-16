require "rails_helper"

# O seed é o único caminho que monta o ambiente de desenvolvimento. Duas
# regressões encontradas na revisão do PR #32 moravam aqui: nenhuma catraca
# nascia online (terminal inutilizável fora dos testes) e reexecutar o seed
# apagava as inscrições do FastPass junto com os time-frames do turno.
RSpec.describe "db/seeds.rb" do
  def semear
    silenciar { load Rails.root.join("db/seeds.rb") }
  end

  def silenciar
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end

  it "deixa as catracas semeadas online, para o terminal operacional funcionar" do
    semear

    expect(Catraca.count).to be_positive
    expect(Catraca.where(online: false)).to be_empty
  end

  it "é idempotente e não apaga time-frames nem inscrições ao rodar de novo" do
    semear
    janela = TimeFrame.joins(:tipo_refeicao).where(tipos_refeicao: { nome: "Almoço" }).first
    aluno = User.find_by!(matricula: "2023123456")
    InscricaoFastpass.create!(aluno: aluno, time_frame: janela, data: Date.current, status: :contemplado)
    contagens = [ Catraca.count, TimeFrame.count, TipoRefeicao.count, Restaurante.count ]

    semear

    expect([ Catraca.count, TimeFrame.count, TipoRefeicao.count, Restaurante.count ]).to eq(contagens)
    expect(InscricaoFastpass.count).to eq(1)
  end

  # Repro da revisão: o admin muda o horário do turno, alunos se inscrevem nas
  # janelas novas e o próximo db:seed reescrevia o horário de volta, levando as
  # janelas e as inscrições na cascata.
  it "preserva o horário do admin e as inscrições feitas nas janelas dele" do
    semear
    almoco = TipoRefeicao.find_by!(nome: "Almoço")
    almoco.update!(hora_inicio: "11:30", hora_fim: "14:00")
    almoco.configurar_time_frames(granularidade: 15, tolerancia: 3) ||
      raise(almoco.errors.full_messages.to_sentence)
    InscricaoFastpass.create!(aluno: User.find_by!(matricula: "2023123456"),
      time_frame: almoco.time_frames.first, data: Date.current, status: :contemplado)
    janelas = almoco.time_frames.count

    semear

    expect(almoco.reload.hora_inicio.strftime("%H:%M")).to eq("11:30")
    expect(almoco.time_frames.count).to eq(janelas)
    expect(InscricaoFastpass.count).to eq(1)
  end
end
