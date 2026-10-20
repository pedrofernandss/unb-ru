Feature: Cadastro de Usuário
  Como um visitante do site
  Eu quero me cadastrar
  Para acessar as áreas restritas do sistema

  Scenario: Cadastro realizado
    Given que eu acesso a página de cadastro
    When eu preencho o campo "Nome Completo" com "Professora Genaina"
    And eu preencho o campo "Matrícula SIGAA ou SIAPE" com "261234567"
    And eu preencho o campo "Senha de Acesso" com "senha123"
    And eu preencho o campo "Confirmar Senha" com "senha123"
    And eu clico no botão "Criar Minha Conta"
    Then eu devo ter meu cadastro realizado
    And ser redirecionado para a página "/login"

  Scenario: Cadastro falha por senhas diferentes
    Given que eu acesso a página de cadastro
    When eu preencho o campo "Nome" com "Professora Genaina"
    And eu preencho o campo "Matrícula SIGAA ou SIAPE" com "261234567"
    And eu preencho o campo "Senha de Acesso" com "senha123"
    And eu preencho o campo "Confirmar Senha" com "senha456"
    And eu clico no botão "Criar Minha Conta"
    Then eu devo ver a mensagem "Não foi possível realizar cadastro"