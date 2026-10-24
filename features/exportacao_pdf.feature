# language: pt
# Issue #11 - Exportação em PDF do Histórico do Estudante
Funcionalidade: Exportação em PDF do Histórico do Estudante
  Como estudante
  Eu quero exportar meu extrato e histórico de refeições como PDF
  Para poder controlar melhor as minhas finanças

  Contexto:
    Dado que eu estou logado como um estudante
    E eu possuo os seguintes lançamentos no meu histórico:
      | data_hora        | evento | restaurante      | valor |
      | 14/05/2024 12:20 | Almoço | RU Darcy Ribeiro | -4.50 |
      | 13/05/2024 19:10 | Jantar | RU Darcy Ribeiro | -4.50 |

  Cenário: Exportação de um período com lançamentos
    Dado que eu acesso a página de extrato de refeições
    Quando eu filtro o período de "01/05/2024" até "31/05/2024"
    E eu clico no botão "Exportar PDF"
    Então eu devo receber um arquivo PDF chamado "extrato-refeicoes.pdf"
    E o PDF deve conter o cabeçalho "Extrato e Histórico de Refeições"

  Cenário: Exportação de um período sem lançamentos
    Dado que eu acesso a página de extrato de refeições
    Quando eu filtro o período de "01/01/2024" até "31/01/2024"
    E eu clico no botão "Exportar PDF"
    Então eu devo ver a mensagem "Não há lançamentos no período selecionado"
    E nenhum arquivo PDF deve ser gerado
