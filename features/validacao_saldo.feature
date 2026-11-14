# language: pt
Funcionalidade: Catraca verifica o saldo do estudante antes de deixá-lo entrar 
  Como aplicação de controle,
  Para que o aluno não entre sem pagar,
  Eu quero ler a identificação do aluno e verificar se há saldo antes de debitar da refeição no momento da passagem.

Contexto: 
    Dado que um funcionário está logado no aplicativo
    E ele está operando a catraca "4"
    E ele está na página de "Validação"
    E existe um aluno cadastrado com matrícula "211048992" e QR Code "QR123"
    Então ele deve ver um painel intitulado "Catraca Atual: 4"
    E uma seção intitulada "Leitura Ótica do QR code"

  Cenário: QR code analisado tem saldo insuficiente (caminho triste)
    Dado que o aluno possui saldo de R$ "2,00"
    E o funcionário tenta validar o QR Code do estudante
    Então o acesso da catraca para o restaurante deve ser bloqueado por "saldo insuficiente"
    E o saldo do aluno deve permanecer em R$ "2,00" 
    E não deve ser registrada nenhuma transação
    E deve ser registrado no histórico da catraca "4" com status "Bloqueado (saldo insuficiente)"
  
  Cenário: Estudante tenta entrar com saldo suficiente (caminho feliz)
    Dado que o aluno possui saldo de R$ "50,00"
    E o funcionário tenta validar o QR Code do estudante
    Então o acesso da catraca para o restaurante deve ser liberado
    E o valor da refeição deve ser descontado do saldo da conta do estudante
    E deve ser registrada uma transação de débito
	  E deve ser registrado no histórico da catraca "4" com status "Liberado"

Cenário: Estudante entra no horário do café da manhã com tarifa reduzida
    Dado que o horário atual é "08:00" no turno "Café da manhã" com tarifa de R$ "2,50"
    E que o aluno possui saldo de R$ "10,00"
    Quando o funcionário tenta validar o QR Code do estudante
    Então o acesso da catraca para o restaurante deve ser liberado
    E o saldo do aluno deve ser atualizado para R$ "7,50"
    E deve ser registrada uma transação de débito no valor de R$ "2,50"

  Cenário: Estudante tem saldo para o café da manhã mas tenta entrar no almoço
    Dado que o horário atual é "12:30" no turno "Almoço" com tarifa de R$ "4,50"
    E que o aluno possui saldo de R$ "3,00"
    Quando o funcionário tenta validar o QR Code do estudante
    Então o acesso da catraca para o restaurante deve ser bloqueado por "saldo insuficiente"
    E o saldo do aluno deve permanecer em R$ "3,00"
    E não deve ser registrada nenhuma transação

  Cenário: Tentativa de acesso fora do horário de refeições
    Dado que o horário atual é "15:45" fora de qualquer turno de refeição
    E que o aluno possui saldo de R$ "50,00"
    Quando o funcionário tenta validar o QR Code do estudante
    Então o acesso da catraca para o restaurante deve ser bloqueado por "fora do turno de refeição"
    E o saldo do aluno deve permanecer em R$ "50,00"
    E não deve ser registrada nenhuma transação