# language: pt
Funcionalidade: O usuário pode ver o cardápio e as diferentes opções da refeição Atual
  Como estudante,
  Para que eu possa decidir qual será minha refeição,
  Eu quero poder ver cardápio das refeições que estão sendo servidas, com todas as opções (padrão, ovolactovegetariano e vegetariano estrito).

  Contexto:
    Dado que o estudante está logado no aplicativo
    E ele está na página inicial
    Então ele deve ver uma seção intitulada "Cardápio"
    E ele deve ver um botão intitulado "Atualizar Cardápio"

  Cenário: Estudante atualiza o cardápio quando não há uma refeição sendo servida. (caminho triste)
    Quando nenhuma refeição está sendo servida
    E estudante aperta o botão "Atualizar Cardápio"
    Então ele deve ver um erro dizendo: "Nenhum cardápio disponível"

  Cenário: Estudante atualiza o cardápio quando há uma refeição sendo servida. (caminho feliz)
    Quando uma refeição está sendo servida
    E estudante aperta o botão "Atualizar Cardápio"
    Então ele deve ver qual refeição está sendo servida (café da manhã, almoço, jantar)
    E todas as opções da refeição (padrão, ovolactovegetariano e vegetariano estrito)
