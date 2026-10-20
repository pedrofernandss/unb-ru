Feature: Inscrição no Sorteio do FastPass
  Como estudante
  Eu quero me inscrever no sorteio gratuito do FastPass escolhendo apenas um time-frame por turno de refeição
  Para tentar garantir meu acesso sem filas

  Background:
    Given que eu estou logado como um estudante
    And o sistema possui os seguintes time-frames de FastPass ativos para o "Almoço":
      | horario       | lote     |
      | 11:30 - 11:45 | Lote #01 |
      | 12:00 - 12:15 | Pico #03 |
      | 12:15 - 12:30 | Pico #04 |

  Scenario: Inscrição com sucesso em um time-frame de pico
    Given que eu acesso a página de "Sorteio FastPass"
    When eu seleciono a opção "12:00 - 12:15" para o turno "Almoço"
    And eu clico no botão "Confirmar Inscrição"
    Then eu devo ver a mensagem "Inscrição no sorteio realizada com sucesso"
    And a área do turno "Almoço" deve exibir o status "Inscrito no Sorteio (12:00 - 12:15)"

  Scenario: Tentativa de inscrição múltipla quando já existe uma inscrição ativa
    Given que eu acesso a página de "Sorteio FastPass"
    And eu já estou inscrito no sorteio do "Almoço" para o horário "12:00 - 12:15"
    When eu seleciono a opção "12:15 - 12:30" para o turno "Almoço"
    And eu clico no botão "Confirmar Inscrição"
    Then eu devo ver a mensagem "Você já possui uma inscrição para o Almoço. Cancele a atual para alterar o horário."