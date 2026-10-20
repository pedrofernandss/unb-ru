Feature: Relatório Global de Acessos
  Como administrador
  Eu quero visualizar o histórico completo de todos os acessos do campus, filtrando e agrupando por restaurante e por catraca
  Para ter uma visão gerencial de toda a operação

  Background:
    Given que eu estou logado como um administrador
    And existe o restaurante "RU Darcy Ribeiro" com 3 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
      | Catraca 04 | 2    |
    And existe o restaurante "RU Gama" com 1 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
    And existem os seguintes acessos registrados:
      | data_hora        | restaurante      | catraca    | matricula | modalidade | status    | valor |
      | 15/10/2026 12:05 | RU Darcy Ribeiro | Catraca 01 | 221045999 | Comum      | Liberado  | 4.50  |
      | 15/10/2026 12:18 | RU Darcy Ribeiro | Catraca 04 | 190088120 | FastPass   | Liberado  | 4.50  |
      | 15/10/2026 12:20 | RU Darcy Ribeiro | Catraca 04 | 231011402 | Comum      | Bloqueado | 0.00  |
      | 15/10/2026 19:02 | RU Gama          | Catraca 01 | 202033481 | Comum      | Liberado  | 4.50  |

  Scenario: Visualizar todos os acessos do campus
    Given que eu acesso a página do relatório global
    Then o relatório deve listar 4 acessos
    And o total de refeições servidas deve ser "3"
    And a arrecadação global deve ser "R$ 13,50"

  Scenario: Agrupar os acessos por restaurante
    Given que eu acesso a página do relatório global
    Then a consolidação do restaurante "RU Darcy Ribeiro" deve exibir 2 acessos liberados e arrecadação de "R$ 9,00"
    And a consolidação do restaurante "RU Gama" deve exibir 1 acessos liberados e arrecadação de "R$ 4,50"

  Scenario: Filtrar os acessos por restaurante
    Given que eu acesso a página do relatório global
    When eu seleciono "RU Gama" no campo "Restaurante"
    And eu clico no botão "Filtrar"
    Then o relatório deve listar 1 acessos
    And o relatório deve exibir o acesso da matrícula "202033481"
    And o relatório não deve exibir o acesso da matrícula "221045999"

  Scenario: Filtrar os acessos por catraca
    Given que eu acesso a página do relatório global
    When eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    And eu seleciono "Catraca 04" no campo "Catraca"
    And eu clico no botão "Filtrar"
    Then o relatório deve listar 2 acessos
    And o relatório deve exibir o acesso da matrícula "190088120"
    And o relatório deve exibir o acesso da matrícula "231011402"

  Scenario: Filtrar por um período sem acessos
    Given que eu acesso a página do relatório global
    When eu preencho o campo "Data Inicial" com "01/10/2026"
    And eu preencho o campo "Data Final" com "02/10/2026"
    And eu clico no botão "Filtrar"
    Then eu devo ver a mensagem "Nenhum acesso encontrado para os filtros selecionados"
    And o relatório deve listar 0 acessos

  Scenario: Filtrar com data inicial posterior à data final
    Given que eu acesso a página do relatório global
    When eu preencho o campo "Data Inicial" com "16/10/2026"
    And eu preencho o campo "Data Final" com "14/10/2026"
    And eu clico no botão "Filtrar"
    Then eu devo ver a mensagem "A data inicial deve ser anterior à data final"

  Scenario: Exportar o relatório em PDF
    Given que eu acesso a página do relatório global
    When eu clico no botão "Exportar PDF Oficial"
    Then eu devo receber um arquivo PDF

  Scenario: Exportar PDF de um relatório sem acessos
    Given que eu acesso a página do relatório global
    When eu preencho o campo "Data Inicial" com "01/10/2026"
    And eu preencho o campo "Data Final" com "02/10/2026"
    And eu clico no botão "Filtrar"
    And eu clico no botão "Exportar PDF Oficial"
    Then eu devo ver a mensagem "Não há acessos para exportar no período selecionado"

  Scenario: Estudante tenta acessar o relatório global
    Given que eu estou logado como um estudante
    When eu tento acessar a página do relatório global
    Then eu devo ser redirecionado para a página "/home"
    And eu devo ver a mensagem "Acesso restrito a administradores"
