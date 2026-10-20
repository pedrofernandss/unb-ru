Feature: Loteria do FastPass termina pelo menos 1 hora antes do início da refeição
  Como estudante,
  Para que eu possa planejar meu horário de ida ao RU,
  Eu quero ser notificado se ganhei ou não o FastPass 1 hora antes do turno.

Background:
  Given que o estudante está logado no aplicativo
  And ele se inscreveu no FastPass para a próxima refeição
  And ele acessa a página do Sorteio do FastPass

Scenario: Falta mais de uma hora até o início da refeição (sad path)
  When a refeição não será servida dentro dos próximos 60 minutos
  Then o estudante deve ver um aviso dizendo: "O Sorteio do FastPass ainda não aconteceu. Volte mais tarde."

Scenario: Falta menos de uma hora até o início da refeição (happy path)
  When a refeição será servida dentro dos próximos 60 minutos
  Then o estudante deve ver uma mensagem dizendo: "Resultado do FastPass"
  And um painel com o resultado ("Você ganhou o FastPass!" ou "Você não ganhou o FastPass. Boa sorte na próxima vez.")