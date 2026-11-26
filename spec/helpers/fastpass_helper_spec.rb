require "rails_helper"

RSpec.describe FastpassHelper, type: :helper do
  describe "#mensagem_do_resultado" do
    it "mostra a mensagem de cada status do sorteio" do
      expect(helper.mensagem_do_resultado(InscricaoFastpass.new(status: :contemplado))).to eq("Você ganhou o FastPass!")
      expect(helper.mensagem_do_resultado(InscricaoFastpass.new(status: :nao_contemplado)))
        .to eq("Você não ganhou o FastPass. Boa sorte na próxima vez.")
      expect(helper.mensagem_do_resultado(InscricaoFastpass.new(status: :inscrito)))
        .to eq("O resultado do sorteio ainda está sendo processado. Volte em instantes.")
    end

    # O enum não aceita outro valor, então o status novo é simulado: o helper deve
    # falhar alto em vez de mostrar "processando" para um status sem mensagem.
    it "levanta erro para status sem mensagem" do
      inscricao = InscricaoFastpass.new
      allow(inscricao).to receive_messages(contemplado?: false, nao_contemplado?: false, inscrito?: false, status: "cancelado")

      expect { helper.mensagem_do_resultado(inscricao) }
        .to raise_error(ArgumentError, "status sem mensagem de resultado: cancelado")
    end
  end
end
