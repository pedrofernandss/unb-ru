module Operador
  class ValidacoesController < BaseController
    before_action :exigir_ponto

    def new
      @historicos = ultimos_historicos
      @chave = nova_chave
    end

    def create
      chave = chave_da_leitura
      return head :unprocessable_entity unless chave

      @resultado = processar_leitura(chave)
      # Guardado antes de `new`, que emite a chave da próxima leitura: o reenvio
      # de uma entrega pendente tem que repetir esta chave, e não abrir outra.
      @chave_em_entrega = params[:chave]
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

    def ultimos_historicos
      catraca_em_operacao.historicos_catraca.includes(:aluno, :processamento_acesso).order(data_hora: :desc).limit(10)
    end

    # A chave identifica uma única leitura: operador, catraca e um UUID.
    def nova_chave
      verificador.generate([ current_user.id, catraca_em_operacao.id, SecureRandom.uuid ], purpose: :acesso)
    end

    # Chave enviada com a leitura, ou nil quando falta a matrícula ou a chave
    # não foi emitida para este operador nesta catraca.
    def chave_da_leitura
      return if params[:matricula].blank?

      usuario_id, catraca_id, chave = verificador.verified(params[:chave], purpose: :acesso)
      chave if emitida_aqui?(usuario_id, catraca_id) && chave.present?
    end

    def emitida_aqui?(usuario_id, catraca_id) = [ usuario_id, catraca_id ] == [ current_user.id, catraca_em_operacao.id ]

    def processar_leitura(chave)
      ValidacaoDeAcesso.processar!(catraca: catraca_em_operacao, matricula: params[:matricula].to_s.strip,
                                   chave: chave, modo: params[:modo].to_s)
    end
  end
end
