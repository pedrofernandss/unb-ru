module Operador
  class ValidacoesController < BaseController
    before_action :exigir_ponto

    def new
      @historicos = catraca_em_operacao.historicos_catraca.includes(:aluno, :processamento_acesso).order(data_hora: :desc).limit(10)
      @chave = verificador.generate([ current_user.id, catraca_em_operacao.id, SecureRandom.uuid ], purpose: :acesso)
    end

    def create
      return head :unprocessable_entity if params[:matricula].blank?

      usuario_id, catraca_id, chave = verificador.verified(params[:chave], purpose: :acesso)
      return head :unprocessable_entity unless usuario_id == current_user.id && catraca_id == catraca_em_operacao.id && chave.present?

      @resultado = ValidacaoDeAcesso.processar!(catraca: catraca_em_operacao,
        matricula: params[:matricula].to_s.strip, chave: chave, modo: params[:modo].to_s)
      new
      render :new
    rescue ValidacaoDeAcesso::EventoIncompativel
      head :conflict
    rescue ArgumentError
      head :unprocessable_entity
    end

    private

    def verificador
      Rails.application.message_verifier(:acesso)
    end
  end
end
