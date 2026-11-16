require "rails_helper"

RSpec.describe User, type: :model do
  def novo_usuario(**atributos)
    User.new({
      nome: "Aluno Teste",
      matricula: "2023123456",
      password: "senha123",
      password_confirmation: "senha123"
    }.merge(atributos))
  end

  describe "validações cadastrais e autenticação" do
    it "salva usuário com dados válidos" do
      expect(novo_usuario.save).to be(true)
    end

    it "exige nome e matrícula obrigatórios" do
      usuario = novo_usuario(nome: "", matricula: "")

      expect(usuario).not_to be_valid
      expect(usuario.errors[:nome]).to include("não pode ficar em branco")
      expect(usuario.errors[:matricula]).to include("não pode ficar em branco")
    end

    it "aceita apenas números na matrícula e remove espaços nas extremidades" do
      expect(novo_usuario(matricula: "ABC123")).not_to be_valid
      expect(novo_usuario(matricula: " 1234567 ")).to be_valid
    end

    it "exige matrícula única" do
      existente = novo_usuario(matricula: "2023999999")
      existente.save!

      duplicado = novo_usuario(matricula: existente.matricula)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:matricula]).to include("já está cadastrada")
    end

    it "exige que senha e confirmação coincidam" do
      usuario = novo_usuario(password_confirmation: "senha456")

      expect(usuario).not_to be_valid
      expect(usuario.errors.full_messages).to include("Confirmação de senha não confere com Senha")
    end

    it "exige senha com ao menos 8 caracteres" do
      expect(novo_usuario(password: "curta", password_confirmation: "curta")).not_to be_valid
    end

    it "autentica com a senha correta e recusa senha incorreta" do
      usuario = novo_usuario
      usuario.save!

      expect(usuario.authenticate("senha123")).to eq(usuario)
      expect(usuario.authenticate("errada")).to be_falsey
    end

    it "recusa saldo negativo" do
      usuario = novo_usuario(saldo: BigDecimal("-0.01"))

      expect(usuario).not_to be_valid
      expect(usuario.errors[:saldo]).to be_present
    end

    it "exige qr_code único quando informado, permitindo múltiplos nulos" do
      novo_usuario(matricula: "2023000001", qr_code: "QR_UNICO_1").save!
      duplicado = novo_usuario(matricula: "2023000002", qr_code: "QR_UNICO_1")

      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:qr_code]).to be_present

      expect(novo_usuario(matricula: "2023000003", qr_code: nil)).to be_valid
      expect(novo_usuario(matricula: "2023000004", qr_code: nil)).to be_valid
    end
  end

  describe "processamento de acesso e débito por turno" do
    let(:restaurante) { criar_restaurante(nome: "RU Darcy Ribeiro") }
    let(:catraca) { Catraca.create!(numero: "4", piso: 1, online: true, restaurante: restaurante) }
    let!(:cafe) { TipoRefeicao.create!(nome: "Café da manhã", hora_inicio: "07:00", hora_fim: "09:30", tarifa: BigDecimal("2.50")) }
    let!(:almoco) { TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:30", tarifa: BigDecimal("4.50")) }

    it "debita a tarifa do turno em BigDecimal e registra transação e histórico quando há saldo" do
      aluno = novo_usuario(matricula: "2023000010", saldo: BigDecimal("20.00"), qr_code: "QR_OK")
      aluno.save!

      evento = ValidacaoDeAcesso.processar!(
        catraca: catraca,
        matricula: aluno.matricula,
        chave: SecureRandom.uuid,
        modo: "Comum",
        agora: Time.zone.parse("2026-10-16 08:00:00")
      )

      expect(evento).to be_liberado
      expect(aluno.reload.saldo).to eq(BigDecimal("17.50"))
      expect(aluno.transacoes.last.valor).to eq(BigDecimal("-2.50"))
      expect(aluno.historicos_catraca.last.catraca).to eq(catraca)
    end

    it "não debita saldo e registra histórico bloqueado quando o saldo é insuficiente para o turno" do
      aluno = novo_usuario(matricula: "2023000011", saldo: BigDecimal("2.00"), qr_code: "QR_SEM_SALDO")
      aluno.save!

      evento = ValidacaoDeAcesso.processar!(
        catraca: catraca,
        matricula: aluno.matricula,
        chave: SecureRandom.uuid,
        modo: "Comum",
        agora: Time.zone.parse("2026-10-16 12:30:00")
      )

      expect(evento).not_to be_liberado
      expect(evento.motivo).to eq("Saldo insuficiente")
      expect(aluno.reload.saldo).to eq(BigDecimal("2.00"))
      expect(aluno.transacoes).to be_empty
      expect(aluno.historicos_catraca.count).to eq(1)
    end
  end
end
