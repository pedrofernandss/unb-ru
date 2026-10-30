class SessionsController < ApplicationController
  allow_unauthenticated_access
  layout "sessao"

  def new
    # Atalho de desenvolvimento: um usuário de cada perfil para entrar sem senha.
    @usuarios_de_exemplo = User.perfis.keys.filter_map { |perfil| User.where(perfil: perfil).order(:id).first } if Rails.env.development?
  end

  def destroy
    terminate_session
    redirect_to login_path, notice: "Você saiu do sistema."
  end
end
