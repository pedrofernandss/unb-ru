# language: pt
# Issue #5 - Configuração de Ponto de Acesso
Funcionalidade: Configuração de Ponto de Acesso
  Como funcionário do restaurante
  Eu quero selecionar em qual restaurante e catraca vou operar logo após o login
  Para que o sistema aplique as regras corretas e grave os logs na catraca certa

  Contexto:
    Dado que eu estou logado como funcionário do restaurante
    E o sistema possui as seguintes catracas cadastradas:
      | restaurante      | catraca    | situacao |
      | RU Darcy Ribeiro | Catraca 03 | Offline  |
      | RU Darcy Ribeiro | Catraca 04 | Online   |

  Cenário: Vinculação a uma catraca disponível
    Dado que eu acesso a página de configuração de ponto de acesso
    Quando eu seleciono a unidade operacional "RU Darcy Ribeiro"
    E eu seleciono a catraca física "Catraca 04"
    E eu clico no botão "Confirmar e Iniciar Operação"
    Então eu devo ser redirecionado para a página "/terminal-de-validacao"
    E a minha sessão deve estar vinculada à catraca "Catraca 04"

  Cenário: Tentativa de vinculação a uma catraca offline
    Dado que eu acesso a página de configuração de ponto de acesso
    Quando eu seleciono a unidade operacional "RU Darcy Ribeiro"
    E eu seleciono a catraca física "Catraca 03"
    E eu clico no botão "Confirmar e Iniciar Operação"
    Então eu devo ver a mensagem "Catraca 03 está offline e não pode ser operada"
    E a minha sessão não deve estar vinculada a nenhuma catraca
