module Admin
  class RelatoriosController < BaseController
    def show
      @relatorio = RelatorioGlobal.new(filtros)
      flash.now[:alert] = @relatorio.errors.full_messages.to_sentence if @relatorio.invalid?
    end

    def exportar
      relatorio = RelatorioGlobal.new(filtros)
      alerta = motivo_para_nao_exportar(relatorio)
      return redirect_to(admin_relatorio_path(relatorio.parametros), alert: alerta) if alerta

      enviar_pdf(relatorio)
    end

    private

    # Filtro inválido ou sem acessos não gera arquivo; nil quando o PDF pode ser exportado.
    def motivo_para_nao_exportar(relatorio)
      return relatorio.errors.full_messages.to_sentence if relatorio.invalid?

      "Não há acessos para exportar no período selecionado" if relatorio.acessos.none?
    end

    def enviar_pdf(relatorio)
      send_data RelatorioGlobalPdf.new(relatorio).render, filename: "relatorio-global.pdf",
                type: "application/pdf", disposition: "attachment"
    end

    def filtros
      params.permit(:restaurante_id, :catraca_id, :data_inicial, :data_final, :pagina).to_h.compact_blank
    end
  end
end
