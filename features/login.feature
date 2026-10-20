Feature: Login de Usuário
  Como um estudante
  Eu quero fazer login no sistema do Restaurante Universitário
  Para acessar meu extrato e outras áreas restritas

  Background:
    Given que existe um estudante cadastrado com a matrícula "261234567" e senha "senha123"

  Scenario: Login
    Given que eu estou na página de login
    When eu preencho o campo "Matrícula" com "261234567"
    And eu preencho o campo "Senha" com "senha123"
    And eu clico no botão "Entrar"
    Then eu devo ser redirecionado para a página inicial

  Scenario: Tentativa de login com senha incorreta
    Given que eu estou na página de login
    When eu preencho o campo "Matrícula" com "261234567"
    And eu preencho o campo "Senha" com "senhaErrada"
    And eu clico no botão "Entrar"
    Then eu devo permanecer na página de login
    And eu devo ver a mensagem "Matrícula ou senha inválidos."

  Scenario: Tentativa de login com matrícula inexistente
    Given que eu estou na página de login
    When eu preencho o campo "Matrícula" com "281234567"
    And eu preencho o campo "Senha" com "senha123"
    And eu clico no botão "Entrar"
    Then eu devo permanecer na página de login
    And eu devo ver a mensagem "E-mail ou senha inválidos."