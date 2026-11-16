require "rails_helper"

RSpec.describe TipoRefeicao, type: :model do
  let!(:cafe) { TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30") }
  let!(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30") }
  let!(:jantar) { TipoRefeicao.create!(nome: "Jantar", hora_inicio: "17:00", hora_fim: "19:30") }

  describe ".vigente_em" do
    it "retorna Café da manhã durante o horário matutino" do
      expect(described_class.vigente_em(Time.zone.parse("2026-11-16 08:15:00"))).to eq(cafe)
    end

    it "retorna Almoço nos limites exatos de início e fim" do
      expect(described_class.vigente_em(Time.zone.parse("2026-11-16 11:00:00"))).to eq(almoco)
      expect(described_class.vigente_em(Time.zone.parse("2026-11-16 14:30:00"))).to eq(almoco)
    end

    it "retorna Jantar durante o turno noturno" do
      expect(described_class.vigente_em(Time.zone.parse("2026-11-16 18:00:00"))).to eq(jantar)
    end

    it "retorna nil fora dos horários de refeição" do
      expect(described_class.vigente_em(Time.zone.parse("2026-11-16 15:45:00"))).to be_nil
    end
  end

  # Os horários ficam gravados em UTC na data 2000-01-01; depois das 22:00 eles passam
  # da meia-noite em UTC, o caso da issue #39.
  describe "sobreposição de turnos" do
    it "recusa turnos sobrepostos depois das 22:00" do
      jantar.update!(hora_inicio: "22:00", hora_fim: "23:00")
      cafe.assign_attributes(hora_inicio: "22:30", hora_fim: "23:30")

      expect(cafe).not_to be_valid
      expect(cafe.errors[:base]).to include("O horário do Café da manhã se sobrepõe ao turno Jantar")
    end

    it "aceita um turno que começa quando o outro termina" do
      jantar.update!(hora_inicio: "22:00", hora_fim: "23:00")
      cafe.assign_attributes(hora_inicio: "23:00", hora_fim: "23:30")

      expect(cafe).to be_valid
    end
  end

  describe ".em_ordem" do
    it "ordena pela hora local, mesmo com turno depois das 22:00" do
      jantar.update!(hora_inicio: "22:00", hora_fim: "23:00")

      expect(described_class.em_ordem).to eq([ cafe, almoco, jantar ])
    end
  end

  describe "#configurar_time_frames" do
    before { almoco.update!(hora_fim: "14:00") }

    it "recusa granularidade com casas decimais" do
      expect(almoco.configurar_time_frames(granularidade: "15.5", tolerancia: "3")).to be(false)
      expect(almoco.errors[:base]).to include("A granularidade deve ser um número")
      expect(almoco.time_frames.reload).to be_empty
    end

    it "recusa tolerância negativa" do
      expect(almoco.configurar_time_frames(granularidade: "15", tolerancia: "-1")).to be(false)
      expect(almoco.errors[:base]).to include("A tolerância deve ser um número inteiro maior ou igual a 0")
    end

    it "mantém as janelas e só muda a tolerância quando a granularidade é a mesma" do
      almoco.configurar_time_frames(granularidade: "15", tolerancia: "3")
      janelas = almoco.time_frames.reload.ids

      expect(almoco.configurar_time_frames(granularidade: "15", tolerancia: "5")).to be(true)
      expect(almoco.time_frames.reload.ids).to eq(janelas)
      expect(almoco.reload.tolerancia_minutos).to eq(5)
    end

    it "não apaga as inscrições dos alunos quando a granularidade é a mesma" do
      almoco.configurar_time_frames(granularidade: "15", tolerancia: "3")
      criar_usuario.inscricoes_fastpass.create!(time_frame: almoco.time_frames.first, data: Date.current)

      expect(almoco.configurar_time_frames(granularidade: "15", tolerancia: "5")).to be(true)
      expect(almoco.inscricoes_fastpass.count).to eq(1)
    end

    it "recria as janelas quando a granularidade muda" do
      almoco.configurar_time_frames(granularidade: "15", tolerancia: "3")

      expect(almoco.configurar_time_frames(granularidade: "30", tolerancia: "3")).to be(true)
      expect(almoco.time_frames.reload.size).to eq(6)
    end

    it "apaga as janelas e a configuração antiga quando o horário muda" do
      almoco.configurar_time_frames(granularidade: "15", tolerancia: "3")
      almoco.update!(hora_fim: "13:00")
      almoco.reload

      expect(almoco.time_frames).to be_empty
      expect(almoco.granularidade_minutos).to be_nil
      expect(almoco.tolerancia_minutos).to be_nil
    end
  end

  describe "#hora_inicio_formatada e #hora_fim_formatada" do
    it "retorna apenas horas e minutos no formato HH:MM" do
      cafe.reload
      expect(cafe.hora_inicio_formatada).to eq("07:00")
      expect(cafe.hora_fim_formatada).to eq("09:30")
    end
  end
end
