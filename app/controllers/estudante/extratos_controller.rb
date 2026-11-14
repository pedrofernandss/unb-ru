module Estudante
  class ExtratosController < BaseController
    def show
      @extrato = Extrato.new(current_user, filtros)
    end

    def comprovante
      @transacao = current_user.transacoes.find(params[:id])
    end

    def exportar
      extrato = Extrato.new(current_user, filtros)
      if extrato.filtradas.none?
        redirect_to extrato_path(extrato.parametros), alert: "Não há lançamentos no período selecionado"
      else
        send_data ExtratoPdf.new(extrato).render, filename: "extrato-refeicoes.pdf",
                  type: "application/pdf", disposition: "attachment"
      end
    end

    private

    def filtros
      params.permit(:data_inicial, :data_final, :tipo, :restaurante_id, :metodo, :pagina)
    end
  end
end
