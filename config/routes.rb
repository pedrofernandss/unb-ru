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
  scope module: :operador do
    get "configuracao-de-ponto", to: "pontos_de_acesso#edit", as: :configuracao_de_ponto
    post "configuracao-de-ponto", to: "pontos_de_acesso#update"
    get "terminal-de-validacao", to: "validacoes#new", as: :terminal_de_validacao
    post "terminal-de-validacao", to: "validacoes#create"
    get "historico-local", to: "historicos#index", as: :historico_local
  end
  get "admin/restaurantes", to: "paginas#em_construcao", as: :admin_restaurantes, defaults: { area: "Administração Geral" }

  # Página de validação de saldo
  get "validacao", to: "validacao#new", as: :validacao
  post "validacao", to: "validacao#create"

  # Administração Geral
  namespace :admin do
    resources :turnos, only: %i[index edit update] do
      patch :configurar_time_frames, on: :collection
    end
  end

  # Portal do Estudante
  scope module: :estudante do
    get "recarga", to: "recargas#new", as: :nova_recarga
    post "recarga", to: "recargas#create", as: nil
    get "recarga/:id", to: "recargas#show", as: :recarga
    post "recarga/:id/confirmar", to: "recargas#confirmar", as: :confirmar_recarga
    get "home", to: "home#index", as: :home
    get "extrato", to: "extratos#show", as: :extrato
    get "extrato/exportar", to: "extratos#exportar", as: :exportar_extrato
    get "extrato/comprovantes/:id", to: "extratos#comprovante", as: :comprovante_extrato

    # Sorteio do FastPass (US13)
    get "fastpass-home", to: "fastpass#show", as: :fastpass
    scope "fastpass", as: "fastpass" do
      resources :inscricoes, controller: "inscricoes_fastpass", only: %i[create destroy]
    end
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
