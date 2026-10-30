# Autenticação por sessão, com a mesma API do gerador de autenticação do Rails 8.
# Toda rota exige login por padrão; use `allow_unauthenticated_access` nos
# controllers públicos (cadastro, login).
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    current_user.present?
  end

  def current_user
    Current.user ||= User.find_by(id: session[:user_id])
  end

  def require_authentication
    return if authenticated?

    session[:return_to_after_authenticating] = request.url if request.get? || request.head?
    redirect_to login_path, alert: "Faça login para continuar."
  end

  def start_new_session_for(user)
    destino = session[:return_to_after_authenticating]
    reset_session # evita fixação de sessão
    session[:user_id] = user.id
    session[:return_to_after_authenticating] = destino if destino
    Current.user = user
  end

  def terminate_session
    Current.user = nil
    reset_session
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || pagina_inicial_de(current_user)
  end

  # Para onde cada perfil vai após o login (rotas mapeadas no spike em docs/).
  def pagina_inicial_de(usuario)
    case usuario.perfil
    when "funcionario" then configuracao_de_ponto_path
    when "administrador" then admin_restaurantes_path
    else home_path
    end
  end
end
