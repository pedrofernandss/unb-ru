# language: pt
Funcionalidade: Extrato de Recargas e Histórico de Refeições
  Como estudante
  Eu quero visualizar meu extrato de recargas e histórico de refeições
  Para ter controle sobre meus gastos e utilizações

	Contexto:
	    Dado que eu estou logado como um estudante
	    E eu possuo o seguinte histórico de uso no Restaurante Universitário:
	      | data_hora        | tipo    | restaurante | metodo      | valor  | comprovante |
	      | 14/05/2024 12:20 | Almoço | RU Darcy Ribeiro - Piso 2          | QR Code App         |  -4.50 | recibo           |
	      | 13/05/2024 19:10 | Jantar  | RU Darcy Ribeiro - Piso 2          | QR Code App |  -4.50 | recibo            |

  Cenário: Visualizar extrato de recargas e histórico de refeições
    Dado que eu estou na página inicial 
    Quando eu clico no botão "Extrato de Refeições" no topo da página
    Então eu devo ser redirecionado para a página "/extrato"
    E eu devo ver um card com o total gasto no mês
    E eu devo ver um card com o total de refeições realizadas
    E eu devo ver um card com o total recarregado
    E eu devo ver uma tabela contendo os cabeçalhos "Data e Hora", "Refeição/Evento", "Restaurante", "Método de Acesso", "Valor" e "Comprovante"
    E a tabela deve exibir a linha com "14/05/2024 12:20", "Almoço", "RU Darcy Ribeiro - Piso 2", "QR Code App", "-R$ 4,50" e "Ver Comprovante"
    E a tabela deve exibir a linha com "13/05/2024 19:10", "Jantar", "RU Darcy Ribeiro - Piso 2", "QR Code App", "-R$ 4,50" e "Ver Comprovante"

	Cenário: Visualizar extrato quando não há transações
	    Dado que eu sou um estudante recém-cadastrado sem histórico
	    Quando eu clico no botão "Extrato de Refeições" no topo da página
    	Então eu devo ser redirecionado para a página "/extrato"
	    Então eu devo ver um card com o total gasto no mês vazio
    	E eu devo ver um card com o total de refeições realizadas vazio
    	E eu devo ver um card com o total recarregado vazio
	    E eu devo ver uma tabela contendo os cabeçalhos "Data e Hora", "Refeição/Evento", "Restaurante", "Método de Acesso", "Valor" e "Comprovante"
    	E a tabela deve estar vazia

