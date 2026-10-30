# Autentica um usuário nos cenários sem passar pela tela de login, usando a
# rota de teste "POST /teste/sessao" definida em config/routes.rb (apenas no
# ambiente de teste) e deixa o navegador na página inicial, como após um login
# real. Funciona com o driver rack_test. O argumento `scope` é aceito por
# compatibilidade com os steps já escritos e ignorado.
module AutenticacaoHelpers
  def login_as(usuario, scope: nil)
    page.driver.post("/teste/sessao", user_id: usuario.id)
    visit "/home"
  end
end

World(AutenticacaoHelpers)
