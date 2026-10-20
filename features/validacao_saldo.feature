Feature: Catraca verifica o saldo do estudante antes de deixá-lo entrar 
  Como aplicação de controle,
  Para que o aluno não entre sem pagar,
  Eu quero ler a identificação do aluno e verificar se há saldo antes de debitar da refeição no momento da passagem.

  Background: 
    Given que um funcionário está logado no aplicativo
    And ele está na página de "Validação"
    Then ele deve ver um painel intitulado "Catraca Atual"
    And uma seção intitulada "Leitura do QR code"

  Scenario: QR code analisado tem saldo insuficiente (sad path)
    When o QR code analisado está associado a uma conta com saldo insuficiente
    And o funcionário tenta validar o QR Code do estudante
	  Then o acesso da catraca para o restaurante deve ser "Bloqueado" para a próxima passagem
  
  Scenario: Estudante tenta entrar com saldo suficiente (happy path)
    When o QR code analisado está associado a uma conta com saldo suficiente
    And o funcionário tenta validar o QR Code do estudante
    Then o preço da refeição deve ser descontado do saldo da conta do estudante
	  And o acesso da catraca para o restaurante deve ser "Liberado" para a próxima passagem
