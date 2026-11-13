module Admin
  class RelatoriosController < BaseController
    def show
      @relatorio = RelatorioGlobal.new(filtros)
      flash.now[:alert] = @relatorio.errors.full_messages.to_sentence if @relatorio.invalid?
    end

    def exportar
      relatorio = RelatorioGlobal.new(filtros)

      if relatorio.invalid?
        redirect_to admin_relatorio_path(relatorio.parametros), alert: relatorio.errors.full_messages.to_sentence
      elsif relatorio.acessos.none?
        redirect_to admin_relatorio_path(relatorio.parametros), alert: "Não há acessos para exportar no período selecionado"
      else
        send_data RelatorioGlobalPdf.new(relatorio).render, filename: "relatorio-global.pdf",
                  type: "application/pdf", disposition: "attachment"
      end
    end

    private

    def filtros
      params.permit(:restaurante_id, :catraca_id, :data_inicial, :data_final).to_h.compact_blank
    end
  end
end
