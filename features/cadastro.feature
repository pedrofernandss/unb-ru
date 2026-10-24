# language: pt
Funcionalidade: Cadastro de Usuário
  Como um visitante do site
  Eu quero me cadastrar
  Para acessar as áreas restritas do sistema

  Cenário: Cadastro realizado
    Dado que eu acesso a página de cadastro
    Quando eu preencho o campo "Nome Completo" com "Professora Genaina"
    E eu preencho o campo "Matrícula SIGAA ou SIAPE" com "261234567"
    E eu preencho o campo "Senha de Acesso" com "senha123"
    E eu preencho o campo "Confirmar Senha" com "senha123"
    E eu clico no botão "Criar Minha Conta"
    Então eu devo ter meu cadastro realizado
    E ser redirecionado para a página "/login"

  Cenário: Cadastro falha por senhas diferentes
    Dado que eu acesso a página de cadastro
    Quando eu preencho o campo "Nome" com "Professora Genaina"
    E eu preencho o campo "Matrícula SIGAA ou SIAPE" com "261234567"
    E eu preencho o campo "Senha de Acesso" com "senha123"
    E eu preencho o campo "Confirmar Senha" com "senha456"
    E eu clico no botão "Criar Minha Conta"
    Então eu devo ver a mensagem "Não foi possível realizar cadastro"