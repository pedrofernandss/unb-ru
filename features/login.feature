# language: pt
Funcionalidade: Login de Usuário
  Como um estudante
  Eu quero fazer login no sistema do Restaurante Universitário
  Para acessar meu extrato e outras áreas restritas

  Contexto:
    Dado que existe um estudante cadastrado com a matrícula "261234567" e senha "senha123"

  Cenário: Login
    Dado que eu estou na página de login
    Quando eu preencho o campo "Matrícula" com "261234567"
    E eu preencho o campo "Senha" com "senha123"
    E eu clico no botão "Entrar"
    Então eu devo ser redirecionado para a página inicial

  Cenário: Tentativa de login com senha incorreta
    Dado que eu estou na página de login
    Quando eu preencho o campo "Matrícula" com "261234567"
    E eu preencho o campo "Senha" com "senhaErrada"
    E eu clico no botão "Entrar"
    Então eu devo permanecer na página de login
    E eu devo ver a mensagem "Matrícula ou senha inválidos."

  Cenário: Tentativa de login com matrícula inexistente
    Dado que eu estou na página de login
    Quando eu preencho o campo "Matrícula" com "281234567"
    E eu preencho o campo "Senha" com "senha123"
    E eu clico no botão "Entrar"
    Então eu devo permanecer na página de login
    E eu devo ver a mensagem "E-mail ou senha inválidos."