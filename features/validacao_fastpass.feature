# Issue #15 - Validação Rigorosa FastPass (BONUS)
Feature: Validação Rigorosa do FastPass na Catraca
  Como aplicação de controle
  Eu quero checar se o aluno sorteado para o FastPass chegou dentro do time-frame vigente
  Para liberar a catraca e debitar a refeição somente quando a regra for cumprida

  Background:
    Given que eu estou logado como funcionário do restaurante
    And o sistema possui as seguintes catracas cadastradas:
      | restaurante      | catraca    | situacao |
      | RU Darcy Ribeiro | Catraca 04 | Online   |
    And a minha sessão está vinculada à catraca "Catraca 04"
    And o sorteio do FastPass do turno "Almoço" teve o seguinte resultado:
      | matricula | estudante           | janela        |
      | 221045999 | Mariana Souza Silva | 12:15 - 12:30 |

  Scenario: Leitura dentro do time-frame sorteado
    Given o estudante de matrícula "221045999" possui saldo de "R$ 18,00"
    When a catraca lê o QR Code da matrícula "221045999" às "12:18:22"
    Then o terminal deve exibir "ACESSO LIBERADO"
    And a catraca física deve ser liberada
    And o saldo do estudante de matrícula "221045999" deve ser "R$ 13,50"

  Scenario: Leitura fora do time-frame sorteado
    Given o estudante de matrícula "221045999" possui saldo de "R$ 18,00"
    When a catraca lê o QR Code da matrícula "221045999" às "12:30:01"
    Then o terminal deve exibir "ACESSO BLOQUEADO"
    And a catraca física não deve ser liberada
    And o saldo do estudante de matrícula "221045999" deve ser "R$ 18,00"

  Scenario: Leitura dentro do time-frame com saldo insuficiente
    Given o estudante de matrícula "221045999" possui saldo de "R$ 2,00"
    When a catraca lê o QR Code da matrícula "221045999" às "12:18:22"
    Then o terminal deve exibir "ACESSO BLOQUEADO"
    And a catraca física não deve ser liberada
    And o saldo do estudante de matrícula "221045999" deve ser "R$ 2,00"
