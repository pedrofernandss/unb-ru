Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: redirect("/home")

  # Cadastro de usuário (US07)
  get  "signup", to: "users#new", as: :signup
  post "signup", to: "users#create"

  # Login (US04): tela única; cada perfil é levado à sua área após autenticar.
  get    "login",  to: "sessions#new", as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Páginas iniciais do funcionário (US05) e do administrador (US08), ainda em construção.
  get "configuracao-de-ponto", to: "paginas#em_construcao", as: :configuracao_de_ponto, defaults: { area: "Terminal Operacional" }
  get "admin/restaurantes", to: "paginas#em_construcao", as: :admin_restaurantes, defaults: { area: "Administração Geral" }

  # Portal do Estudante
  scope module: :estudante do
    get "home", to: "home#index", as: :home
    get "extrato", to: "extratos#show", as: :extrato
    get "extrato/comprovantes/:id", to: "extratos#comprovante", as: :comprovante_extrato
  end

  if Rails.env.local?
    # Atalho para autenticar sem a tela de login. Em teste é usado pelo helper
    # `login_as` (features/support/autenticacao.rb e test/test_helper.rb); em
    # desenvolvimento, pelos botões de exemplo da página /login. Não existe em produção.
    post "teste/sessao", to: ->(env) {
      requisicao = ActionDispatch::Request.new(env)
      requisicao.session[:user_id] = requisicao.params["user_id"]
      [ 303, { "Location" => "/home" }, [] ]
    }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
