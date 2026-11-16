# Páginas provisórias das áreas que ainda não foram implementadas.
class PaginasController < ApplicationController
  layout "sessao"

  def em_construcao
    @area = params[:area]
  end
end
