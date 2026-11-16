class SessionsController < ApplicationController
  allow_unauthenticated_access
  layout "sessao"

  def new
    redirect_to after_authentication_url if authenticated?

    # Atalho de desenvolvimento: um usuário de cada perfil para entrar sem senha.
    @usuarios_de_exemplo = User.perfis.keys.filter_map { |perfil| User.where(perfil: perfil).order(:id).first } if Rails.env.development?
  end

  def create
    usuario = User.find_by(matricula: params[:matricula].to_s.strip)

    if usuario&.authenticate(params[:senha].to_s)
      start_new_session_for(usuario)
      redirect_to after_authentication_url
    else
      flash.now[:alert] = "Matrícula ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to login_path, notice: "Você saiu do sistema."
  end
end
