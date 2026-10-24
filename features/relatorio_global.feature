# language: pt
Funcionalidade: Relatório Global de Acessos
  Como administrador
  Eu quero visualizar o histórico completo de todos os acessos do campus, filtrando e agrupando por restaurante e por catraca
  Para ter uma visão gerencial de toda a operação

  Contexto:
    Dado que eu estou logado como um administrador
    E existe o restaurante "RU Darcy Ribeiro" com 3 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
      | Catraca 04 | 2    |
    E existe o restaurante "RU Gama" com 1 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
    E existem os seguintes acessos registrados:
      | data_hora        | restaurante      | catraca    | matricula | modalidade | status    | valor |
      | 15/10/2026 12:05 | RU Darcy Ribeiro | Catraca 01 | 221045999 | Comum      | Liberado  | 4.50  |
      | 15/10/2026 12:18 | RU Darcy Ribeiro | Catraca 04 | 190088120 | FastPass   | Liberado  | 4.50  |
      | 15/10/2026 12:20 | RU Darcy Ribeiro | Catraca 04 | 231011402 | Comum      | Bloqueado | 0.00  |
      | 15/10/2026 19:02 | RU Gama          | Catraca 01 | 202033481 | Comum      | Liberado  | 4.50  |

  Cenário: Visualizar todos os acessos do campus
    Dado que eu acesso a página do relatório global
    Então o relatório deve listar 4 acessos
    E o total de refeições servidas deve ser "3"
    E a arrecadação global deve ser "R$ 13,50"

  Cenário: Agrupar os acessos por restaurante
    Dado que eu acesso a página do relatório global
    Então a consolidação do restaurante "RU Darcy Ribeiro" deve exibir 2 acessos liberados e arrecadação de "R$ 9,00"
    E a consolidação do restaurante "RU Gama" deve exibir 1 acessos liberados e arrecadação de "R$ 4,50"

  Cenário: Filtrar os acessos por restaurante
    Dado que eu acesso a página do relatório global
    Quando eu seleciono "RU Gama" no campo "Restaurante"
    E eu clico no botão "Filtrar"
    Então o relatório deve listar 1 acessos
    E o relatório deve exibir o acesso da matrícula "202033481"
    E o relatório não deve exibir o acesso da matrícula "221045999"

  Cenário: Filtrar os acessos por catraca
    Dado que eu acesso a página do relatório global
    Quando eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E eu seleciono "Catraca 04" no campo "Catraca"
    E eu clico no botão "Filtrar"
    Então o relatório deve listar 2 acessos
    E o relatório deve exibir o acesso da matrícula "190088120"
    E o relatório deve exibir o acesso da matrícula "231011402"

  Cenário: Filtrar por um período sem acessos
    Dado que eu acesso a página do relatório global
    Quando eu preencho o campo "Data Inicial" com "01/10/2026"
    E eu preencho o campo "Data Final" com "02/10/2026"
    E eu clico no botão "Filtrar"
    Então eu devo ver a mensagem "Nenhum acesso encontrado para os filtros selecionados"
    E o relatório deve listar 0 acessos

  Cenário: Filtrar com data inicial posterior à data final
    Dado que eu acesso a página do relatório global
    Quando eu preencho o campo "Data Inicial" com "16/10/2026"
    E eu preencho o campo "Data Final" com "14/10/2026"
    E eu clico no botão "Filtrar"
    Então eu devo ver a mensagem "A data inicial deve ser anterior à data final"

  Cenário: Exportar o relatório em PDF
    Dado que eu acesso a página do relatório global
    Quando eu clico no botão "Exportar PDF Oficial"
    Então eu devo receber um arquivo PDF

  Cenário: Exportar PDF de um relatório sem acessos
    Dado que eu acesso a página do relatório global
    Quando eu preencho o campo "Data Inicial" com "01/10/2026"
    E eu preencho o campo "Data Final" com "02/10/2026"
    E eu clico no botão "Filtrar"
    E eu clico no botão "Exportar PDF Oficial"
    Então eu devo ver a mensagem "Não há acessos para exportar no período selecionado"

  Cenário: Estudante tenta acessar o relatório global
    Dado que eu estou logado como um estudante
    Quando eu tento acessar a página do relatório global
    Então eu devo ser redirecionado para a página "/home"
    E eu devo ver a mensagem "Acesso restrito a administradores"
