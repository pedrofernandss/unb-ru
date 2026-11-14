module Funcionario
  class HistoricoLocalController < ApplicationController
    before_action :verificar_funcionario!

    def index
      @catraca = Catraca.find_by(id: session[:catraca_em_operacao_id]) || current_user.catraca
      @acessos = if @catraca
        @catraca.historicos_catraca.includes(:aluno).order(data_hora: :desc)
      else
        []
      end
    end

    private

    def verificar_funcionario!
      unless current_user&.funcionario?
        redirect_to root_path, alert: "Acesso não autorizado!"
      end
    end
  end
end
