Feature: Funcionário do restaurante consegue ver o histórico de acesso da sua catraca
  Como funcionário,
  Para realizar auditorias ou conferências locais de fluxo.
  Eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento,

  Background:
    Given que um funcionário está logado no aplicativo
    And ele está na página de "Histórico Local"

  Scenario: Funcionário não está gerenciando uma catraca (sad path)
    When o funcionário não está gerindo nenhuma catraca
    Then a página deve mostrar um texto dizendo "Você não está gerindo nenhuma catraca no momento"

  Scenario: Funcionário está gerenciando uma catraca (happy path)
    When o funcionário está gerindo uma catraca
    And a catraca que ele está gerindo tem o seguinte histórico:
      | data_hora           | matricula_disc    | modo_validacao    | tarifa | status_catraca                 |
	  | 16/10/2026 12:18:22 | 211048992         | Comum             | R$4,50 | Liberado                       |
	  | 16/10/2024 12:17:45 | 221012443         | Comum             | R$4,50 | Bloqueado (saldo insuficiente) |
    Then ele deve ver um texto dizendo a catraca que ele está gerenciando
    And ele deve ver uma tabela com os cabeçalhos: "Horário", "Matrícula (Discente)", "Modo de Validação", "Tarifa" e "Status da Catraca"
    And a tabela deve conter a linha com: "12:18:22", "211048992", "Comum", "R$4,50" e "Liberado"
    And a tabela deve conter a linha com: "12:17:45", "221012443", "Comum", "R$4,50" e "Bloqueado (saldo insuficiente)"
