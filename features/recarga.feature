# language: pt
# Issue #2 - Recarga de Saldo (MVP)
Funcionalidade: Recarga de Saldo
  Como estudante
  Eu quero adicionar créditos à minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes

  Contexto:
    Dado que eu estou logado como um estudante
    E o meu saldo atual é de "R$ 18,00"

  Cenário: Recarga de um pacote de refeições via PIX
    Dado que eu acesso a página de recarga de saldo
    Quando eu escolho o pacote "5 Refeições"
    E eu seleciono o método de pagamento "PIX Instantâneo"
    E eu clico no botão "Confirmar"
    E o provedor de pagamento aprova a transação
    Então eu devo ver a mensagem "Recarga realizada com sucesso"
    E o meu saldo deve ser "R$ 40,50"

  Cenário: Recarga com quantidade acima do limite permitido
    Dado que eu acesso a página de recarga de saldo
    Quando eu informo a quantidade personalizada de "51" refeições
    E eu clico no botão "Confirmar"
    Então eu devo ver a mensagem "Informe uma quantidade entre 1 e 50 refeições"
    E o meu saldo deve ser "R$ 18,00"

  Cenário: Recarga recusada pelo provedor de pagamento
    Dado que eu acesso a página de recarga de saldo
    Quando eu escolho o pacote "10 Refeições"
    E eu seleciono o método de pagamento "Cartão de Crédito"
    E eu clico no botão "Confirmar"
    E o provedor de pagamento recusa a transação
    Então eu devo ver a mensagem "Não foi possível concluir o pagamento"
    E o meu saldo deve ser "R$ 18,00"
