module Admin
  # Controllers da Administração Geral: exigem perfil de administrador e usam o layout "admin".
  class BaseController < ApplicationController
    layout "admin"

    before_action :exigir_administrador

    private

    # As validações de unicidade consultam antes de gravar; em requisições simultâneas quem
    # barra a duplicata é o índice único, e o erro vira a mesma mensagem da validação.
    def salvar_sem_duplicar(registro, erro)
      yield
    rescue ActiveRecord::RecordNotUnique
      registro.errors.add(:base, erro)
      false
    end

    def exigir_administrador
      return if current_user.administrador?

      redirect_to home_path, alert: "Acesso restrito a administradores"
    end
  end
end
