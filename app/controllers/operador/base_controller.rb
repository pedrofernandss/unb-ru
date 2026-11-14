module Operador
  class BaseController < ApplicationController
    layout "operador"
    before_action :exigir_funcionario
    helper_method :catraca_em_operacao

    private

    def exigir_funcionario
      redirect_to home_path, alert: "Acesso restrito a funcionários" unless current_user.funcionario?
    end

    # Uma única fonte: sessão autenticada, apagada pelo reset_session no login/logout.
    # funcionario_id continua sendo o responsável cadastral, não a sessão de operação.
    def catraca_em_operacao
      @catraca_em_operacao ||= Catraca.includes(:restaurante).find_by(id: session[:catraca_em_operacao_id], online: true)
    end

    def exigir_ponto
      return if catraca_em_operacao

      session.delete(:catraca_em_operacao_id)
      redirect_to configuracao_de_ponto_path, alert: "Selecione uma catraca online para iniciar a operação"
    end
  end
end
