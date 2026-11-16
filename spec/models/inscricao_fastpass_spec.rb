require "rails_helper"

RSpec.describe InscricaoFastpass, type: :model do
  let(:aluno) { criar_usuario }
  let(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:00") }
  let(:janela) { almoco.time_frames.create!(inicio: "12:00", fim: "12:15") }

  it "o banco barra a mesma janela duas vezes no dia mesmo sem a validação" do
    described_class.create!(aluno: aluno, time_frame: janela, data: Date.current)
    repetida = described_class.new(aluno: aluno, time_frame: janela, data: Date.current)

    expect { repetida.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "permite a mesma janela em outro dia" do
    described_class.create!(aluno: aluno, time_frame: janela, data: Date.yesterday)

    expect(described_class.new(aluno: aluno, time_frame: janela, data: Date.current).save).to be(true)
  end

  it "calcula o início do turno com a data da inscrição e o horário do turno" do
    inscricao = described_class.new(time_frame: janela, data: Date.new(2026, 11, 20))

    expect(inscricao.inicio_do_turno).to eq(Time.zone.local(2026, 11, 20, 11, 0))
  end

  it "libera o resultado a partir de 1 hora antes do turno" do
    inscricao = described_class.new(time_frame: janela, data: Date.new(2026, 11, 20))

    travel_to(Time.zone.local(2026, 11, 20, 9, 59, 59)) { expect(inscricao.resultado_liberado?).to be(false) }
    travel_to(Time.zone.local(2026, 11, 20, 10, 0, 0)) { expect(inscricao.resultado_liberado?).to be(true) }
  end

  it "não libera no horário de hoje o resultado da inscrição de amanhã" do
    inscricao = described_class.new(time_frame: janela, data: Date.new(2026, 11, 21))

    travel_to(Time.zone.local(2026, 11, 20, 10, 30)) { expect(inscricao.resultado_liberado?).to be(false) }
  end
end
