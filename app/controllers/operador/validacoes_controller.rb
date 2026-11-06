module Operador
  class ValidacoesController < BaseController
    before_action :exigir_ponto

    def new
      @historicos = catraca_em_operacao.historicos_catraca.includes(:aluno).order(data_hora: :desc).limit(10)
    end
  end
end
