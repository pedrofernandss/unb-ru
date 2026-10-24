# language: pt
# Issue #15 - Validação Rigorosa FastPass (BONUS)
Funcionalidade: Validação Rigorosa do FastPass na Catraca
  Como aplicação de controle
  Eu quero checar se o aluno sorteado para o FastPass chegou dentro do time-frame vigente
  Para liberar a catraca e debitar a refeição somente quando a regra for cumprida

  Contexto:
    Dado que eu estou logado como funcionário do restaurante
    E o sistema possui as seguintes catracas cadastradas:
      | restaurante      | catraca    | situacao |
      | RU Darcy Ribeiro | Catraca 04 | Online   |
    E a minha sessão está vinculada à catraca "Catraca 04"
    E o sorteio do FastPass do turno "Almoço" teve o seguinte resultado:
      | matricula | estudante           | janela        |
      | 221045999 | Mariana Souza Silva | 12:15 - 12:30 |

  Cenário: Leitura dentro do time-frame sorteado
    Dado o estudante de matrícula "221045999" possui saldo de "R$ 18,00"
    Quando a catraca lê o QR Code da matrícula "221045999" às "12:18:22"
    Então o terminal deve exibir "ACESSO LIBERADO"
    E a catraca física deve ser liberada
    E o saldo do estudante de matrícula "221045999" deve ser "R$ 13,50"

  Cenário: Leitura fora do time-frame sorteado
    Dado o estudante de matrícula "221045999" possui saldo de "R$ 18,00"
    Quando a catraca lê o QR Code da matrícula "221045999" às "12:30:01"
    Então o terminal deve exibir "ACESSO BLOQUEADO"
    E a catraca física não deve ser liberada
    E o saldo do estudante de matrícula "221045999" deve ser "R$ 18,00"

  Cenário: Leitura dentro do time-frame com saldo insuficiente
    Dado o estudante de matrícula "221045999" possui saldo de "R$ 2,00"
    Quando a catraca lê o QR Code da matrícula "221045999" às "12:18:22"
    Então o terminal deve exibir "ACESSO BLOQUEADO"
    E a catraca física não deve ser liberada
    E o saldo do estudante de matrícula "221045999" deve ser "R$ 2,00"
