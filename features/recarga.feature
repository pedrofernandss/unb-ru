# Issue #2 - Recarga de Saldo (MVP)
Feature: Recarga de Saldo
  Como estudante
  Eu quero adicionar créditos à minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes

  Background:
    Given que eu estou logado como um estudante
    And o meu saldo atual é de "R$ 18,00"

  Scenario: Recarga de um pacote de refeições via PIX
    Given que eu acesso a página de recarga de saldo
    When eu escolho o pacote "5 Refeições"
    And eu seleciono o método de pagamento "PIX Instantâneo"
    And eu clico no botão "Confirmar"
    And o provedor de pagamento aprova a transação
    Then eu devo ver a mensagem "Recarga realizada com sucesso"
    And o meu saldo deve ser "R$ 40,50"

  Scenario: Recarga com quantidade acima do limite permitido
    Given que eu acesso a página de recarga de saldo
    When eu informo a quantidade personalizada de "51" refeições
    And eu clico no botão "Confirmar"
    Then eu devo ver a mensagem "Informe uma quantidade entre 1 e 50 refeições"
    And o meu saldo deve ser "R$ 18,00"

  Scenario: Recarga recusada pelo provedor de pagamento
    Given que eu acesso a página de recarga de saldo
    When eu escolho o pacote "10 Refeições"
    And eu seleciono o método de pagamento "Cartão de Crédito"
    And eu clico no botão "Confirmar"
    And o provedor de pagamento recusa a transação
    Then eu devo ver a mensagem "Não foi possível concluir o pagamento"
    And o meu saldo deve ser "R$ 18,00"
