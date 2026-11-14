# language: pt
Funcionalidade: Funcionário do restaurante consegue ver o histórico de acesso da sua catraca
  Como funcionário,
  Para realizar auditorias ou conferências locais de fluxo.
  Eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento,

  Contexto:
    Dado que um funcionário está logado no aplicativo

  Cenário: Funcionário não está gerenciando uma catraca (caminho triste)
    Quando o funcionário não está gerindo nenhuma catraca
    E ele acessa a página de "Histórico Local"
    Então ele deve ser redirecionado para a configuração de ponto de acesso
    E a página deve mostrar um texto dizendo "Selecione uma catraca online para iniciar a operação"

  Cenário: Funcionário está gerenciando uma catraca (caminho feliz)
    Quando o funcionário está gerindo uma catraca
    E a catraca que ele está gerindo tem o seguinte histórico:
      | data_hora           | matricula_disc | modo_validacao | tarifa | status_catraca | motivo              |
      | 16/10/2026 12:18:22 | 211048992      | Comum          | R$4,50 | Liberado       | Validação concluída |
      | 16/10/2024 12:17:45 | 221012443      | Comum          | R$0,00 | Bloqueado      | Saldo insuficiente  |
    E ele acessa a página de "Histórico Local"
    Então ele deve ver um texto dizendo a catraca que ele está gerenciando
    E ele deve ver uma tabela com os cabeçalhos: "Horário", "Matrícula (Discente)", "Modo de Validação", "Tarifa", "Status da Catraca" e "Motivo"
    E a tabela deve conter a linha com: "12:18:22", "211048992", "Comum", "R$4,50", "Liberado" e "Validação concluída"
    E a tabela deve conter a linha com: "12:17:45", "221012443", "Comum", "R$0,00", "Bloqueado" e "Saldo insuficiente"