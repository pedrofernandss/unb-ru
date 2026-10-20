Feature: Extrato de Recargas e Histórico de Refeições
  Como estudante
  Eu quero visualizar meu extrato de recargas e histórico de refeições
  Para ter controle sobre meus gastos e utilizações

	Background:
	    Given que eu estou logado como um estudante
	    And eu possuo o seguinte histórico de uso no Restaurante Universitário:
	      | data_hora        | tipo    | restaurante | metodo      | valor  | comprovante |
	      | 14/05/2024 12:20 | Almoço | RU Darcy Ribeiro - Piso 2          | QR Code App         |  -4.50 | recibo           |
	      | 13/05/2024 19:10 | Jantar  | RU Darcy Ribeiro - Piso 2          | QR Code App |  -4.50 | recibo            |

  Scenario: Visualizar extrato de recargas e histórico de refeições
    Given que eu estou na página inicial 
    When eu clico no botão "Extrato de Refeições" no topo da página
    Then eu devo ser redirecionado para a página "/extrato"
    And eu devo ver um card com o total gasto no mês
    And eu devo ver um card com o total de refeições realizadas
    And eu devo ver um card com o total recarregado
    And eu devo ver uma tabela contendo os cabeçalhos "Data e Hora", "Refeição/Evento", "Restaurante", "Método de Acesso", "Valor" e "Comprovante"
    And a tabela deve exibir a linha com "14/05/2024 12:20", "Almoço", "RU Darcy Ribeiro - Piso 2", "QR Code App", "-R$ 4,50" e "Ver Comprovante"
    And a tabela deve exibir a linha com "13/05/2024 19:10", "Jantar", "RU Darcy Ribeiro - Piso 2", "QR Code App", "-R$ 4,50" e "Ver Comprovante"

	Scenario: Visualizar extrato quando não há transações
	    Given que eu sou um estudante recém-cadastrado sem histórico
	    When eu clico no botão "Extrato de Refeições" no topo da página
    	Then eu devo ser redirecionado para a página "/extrato"
	    Then eu devo ver um card com o total gasto no mês vazio
    	And eu devo ver um card com o total de refeições realizadas vazio
    	And eu devo ver um card com o total recarregado vazio
	    And eu devo ver uma tabela contendo os cabeçalhos "Data e Hora", "Refeição/Evento", "Restaurante", "Método de Acesso", "Valor" e "Comprovante"
    	And a tabela deve estar vazia

