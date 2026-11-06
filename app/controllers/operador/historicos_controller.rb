module Operador
  class HistoricosController < BaseController
    before_action :exigir_ponto

    def index
      @historicos = catraca_em_operacao.historicos_catraca.includes(:aluno).order(data_hora: :desc).limit(100)
    end
  end
end
