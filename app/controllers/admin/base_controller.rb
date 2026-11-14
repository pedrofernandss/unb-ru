module Admin
  # Controllers da Administração Geral: exigem perfil de administrador e usam o layout "admin".
  class BaseController < ApplicationController
    layout "admin"

    before_action :exigir_administrador

    private

    def exigir_administrador
      return if current_user.administrador?

      redirect_to home_path, alert: "Acesso restrito a administradores"
    end
  end
end
