module Estudante
  class ExtratosController < BaseController
    def show
      @extrato = Extrato.new(current_user, filtros)
    end

    def comprovante
      @transacao = current_user.transacoes.find(params[:id])
    end

    private

    def filtros
      params.permit(:data_inicial, :data_final, :tipo, :restaurante_id, :metodo, :pagina)
    end
  end
end
