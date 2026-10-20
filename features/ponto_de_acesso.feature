# Issue #5 - Configuração de Ponto de Acesso
Feature: Configuração de Ponto de Acesso
  Como funcionário do restaurante
  Eu quero selecionar em qual restaurante e catraca vou operar logo após o login
  Para que o sistema aplique as regras corretas e grave os logs na catraca certa

  Background:
    Given que eu estou logado como funcionário do restaurante
    And o sistema possui as seguintes catracas cadastradas:
      | restaurante      | catraca    | situacao |
      | RU Darcy Ribeiro | Catraca 03 | Offline  |
      | RU Darcy Ribeiro | Catraca 04 | Online   |

  Scenario: Vinculação a uma catraca disponível
    Given que eu acesso a página de configuração de ponto de acesso
    When eu seleciono a unidade operacional "RU Darcy Ribeiro"
    And eu seleciono a catraca física "Catraca 04"
    And eu clico no botão "Confirmar e Iniciar Operação"
    Then eu devo ser redirecionado para a página "/terminal-de-validacao"
    And a minha sessão deve estar vinculada à catraca "Catraca 04"

  Scenario: Tentativa de vinculação a uma catraca offline
    Given que eu acesso a página de configuração de ponto de acesso
    When eu seleciono a unidade operacional "RU Darcy Ribeiro"
    And eu seleciono a catraca física "Catraca 03"
    And eu clico no botão "Confirmar e Iniciar Operação"
    Then eu devo ver a mensagem "Catraca 03 está offline e não pode ser operada"
    And a minha sessão não deve estar vinculada a nenhuma catraca
