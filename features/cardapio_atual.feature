Feature: O usuário pode ver o cardápio e as diferentes opções da refeição Atual
  Como estudante,
  Para que eu possa decidir qual será minha refeição,
  Eu quero poder ver cardápio das refeições que estão sendo servidas, com todas as opções (padrão, ovolactovegetariano e vegetariano estrito).

  Background:
    Given que o estudante está logado no aplicativo
    And ele está na página inicial
    Then ele deve ver uma seção intitulada "Cardápio"
    And ele deve ver um botão intitulado "Atualizar Cardápio"

  Scenario: Estudante atualiza o cardápio quando não há uma refeição sendo servida. (sad path)
    When nenhuma refeição está sendo servida
    And estudante aperta o botão "Atualizar Cardápio"
    Then ele deve ver um erro dizendo: "Nenhum cardápio disponível"

  Scenario: Estudante atualiza o cardápio quando há uma refeição sendo servida. (happy path)
    When uma refeição está sendo servida
    And estudante aperta o botão "Atualizar Cardápio"
    Then ele deve ver qual refeição está sendo servida (café da manhã, almoço, jantar)
    And todas as opções da refeição (padrão, ovolactovegetariano e vegetariano estrito)
