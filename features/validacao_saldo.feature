# language: pt
Funcionalidade: Catraca verifica o saldo do estudante antes de deixá-lo entrar 
  Como aplicação de controle,
  Para que o aluno não entre sem pagar,
  Eu quero ler a identificação do aluno e verificar se há saldo antes de debitar da refeição no momento da passagem.

  Contexto: 
    Dado que um funcionário está logado no aplicativo
    E ele está na página de "Validação"
    Então ele deve ver um painel intitulado "Catraca Atual"
    E uma seção intitulada "Leitura do QR code"

  Cenário: QR code analisado tem saldo insuficiente (caminho triste)
    Quando o QR code analisado está associado a uma conta com saldo insuficiente
    E o funcionário tenta validar o QR Code do estudante
	  Então o acesso da catraca para o restaurante deve ser "Bloqueado" para a próxima passagem
  
  Cenário: Estudante tenta entrar com saldo suficiente (caminho feliz)
    Quando o QR code analisado está associado a uma conta com saldo suficiente
    E o funcionário tenta validar o QR Code do estudante
    Então o preço da refeição deve ser descontado do saldo da conta do estudante
	  E o acesso da catraca para o restaurante deve ser "Liberado" para a próxima passagem
