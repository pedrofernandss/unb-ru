class SessionsController < ApplicationController
  allow_unauthenticated_access
  layout "sessao"

  def new
    redirect_to after_authentication_url if authenticated?

    @usuarios_de_exemplo = usuarios_de_exemplo if Rails.env.development?
  end

  def create
    usuario = usuario_autenticado

    if usuario
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

  private

  # Usuário cuja matrícula e senha conferem; nil caso contrário.
  def usuario_autenticado
    usuario = User.find_by(matricula: params[:matricula].to_s.strip)
    usuario if usuario&.authenticate(params[:senha].to_s)
  end

  # Atalho de desenvolvimento: um usuário de cada perfil para entrar sem senha.
  def usuarios_de_exemplo
    User.perfis.keys.filter_map { |perfil| User.where(perfil: perfil).order(:id).first }
  end
end
