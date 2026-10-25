# language: pt
Funcionalidade: Loteria do FastPass termina pelo menos 1 hora antes do início da refeição
  Como estudante,
  Para que eu possa planejar meu horário de ida ao RU,
  Eu quero ser notificado se ganhei ou não o FastPass 1 hora antes do turno.

Contexto:
  Dado que o estudante está logado no aplicativo
  E ele se inscreveu no FastPass para a próxima refeição
  E ele acessa a página do Sorteio do FastPass

Cenário: Falta mais de uma hora até o início da refeição (caminho triste)
  Quando a refeição não será servida dentro dos próximos 60 minutos
  Então o estudante deve ver um aviso dizendo: "O Sorteio do FastPass ainda não aconteceu. Volte mais tarde."

Cenário: Falta menos de uma hora até o início da refeição (caminho feliz)
  Quando a refeição será servida dentro dos próximos 60 minutos
  Então o estudante deve ver uma mensagem dizendo: "Resultado do FastPass"
  E um painel com o resultado ("Você ganhou o FastPass!" ou "Você não ganhou o FastPass. Boa sorte na próxima vez.")