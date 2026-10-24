# language: pt
Funcionalidade: Gestão de Restaurantes e Catracas
  Como administrador
  Eu quero cadastrar, editar e remover restaurantes e suas catracas físicas
  Para que os funcionários possam selecioná-las na Aplicação de Controle

  Contexto:
    Dado que eu estou logado como um administrador
    E existe o restaurante "RU Darcy Ribeiro" com 3 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
      | Catraca 02 | 1    |

  Cenário: Cadastrar um novo restaurante
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Cadastrar Restaurante"
    E eu preencho o campo "Nome da Unidade" com "RU Gama"
    E eu preencho o campo "Número de Pisos" com "1"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Restaurante cadastrado com sucesso"
    E o restaurante "RU Gama" deve aparecer na lista de unidades cadastradas

  Cenário: Cadastrar restaurante sem nome
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Cadastrar Restaurante"
    E eu deixo o campo "Nome da Unidade" vazio
    E eu preencho o campo "Número de Pisos" com "1"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Nome da Unidade não pode ficar em branco"

  Esquema do Cenário: Cadastrar restaurante com número de pisos inválido
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Cadastrar Restaurante"
    E eu preencho o campo "Nome da Unidade" com "RU Gama"
    E eu preencho o campo "Número de Pisos" com "<pisos>"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "<mensagem>"

    Exemplos:
      | pisos | mensagem                                     |
      |       | Número de Pisos não pode ficar em branco     |
      | 0     | Número de Pisos deve ser maior que 0         |
      | três  | Número de Pisos deve ser um número           |

  Cenário: Cadastrar restaurante com nome já existente
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Cadastrar Restaurante"
    E eu preencho o campo "Nome da Unidade" com "RU Darcy Ribeiro"
    E eu preencho o campo "Número de Pisos" com "2"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Já existe um restaurante com esse nome"

  Cenário: Editar o nome de um restaurante
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Editar Unidade" do restaurante "RU Darcy Ribeiro"
    E eu preencho o campo "Nome da Unidade" com "RU Darcy Ribeiro - Central"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Restaurante atualizado com sucesso"
    E o restaurante "RU Darcy Ribeiro - Central" deve aparecer na lista de unidades cadastradas

  Cenário: Associar uma nova catraca a um restaurante
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Associar Nova Catraca"
    E eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E eu preencho o campo "Nome da Catraca" com "Catraca 04"
    E eu preencho o campo "Piso" com "2"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Catraca associada com sucesso"
    E a catraca "Catraca 04" deve aparecer no piso 2 do restaurante "RU Darcy Ribeiro"

  Esquema do Cenário: Associar catraca com piso inválido
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Associar Nova Catraca"
    E eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E eu preencho o campo "Nome da Catraca" com "Catraca 04"
    E eu preencho o campo "Piso" com "<piso>"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "<mensagem>"

    Exemplos:
      | piso | mensagem                                  |
      | 0    | Piso deve estar entre 1 e 3               |
      | 4    | Piso deve estar entre 1 e 3               |
      | dois | Piso deve ser um número                   |

  Cenário: Associar catraca com nome repetido no mesmo restaurante
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Associar Nova Catraca"
    E eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E eu preencho o campo "Nome da Catraca" com "Catraca 01"
    E eu preencho o campo "Piso" com "1"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Já existe uma catraca com esse nome neste restaurante"

  Cenário: Remover uma catraca
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Remover" da catraca "Catraca 02"
    Então eu devo ver a mensagem "Catraca removida com sucesso"
    E a catraca "Catraca 02" não deve aparecer no restaurante "RU Darcy Ribeiro"

  Cenário: Remover restaurante que ainda possui catracas
    Dado que eu acesso a página de gestão de restaurantes
    Quando eu clico no botão "Remover Unidade" do restaurante "RU Darcy Ribeiro"
    Então eu devo ver a mensagem "Remova as catracas antes de excluir o restaurante"
    E o restaurante "RU Darcy Ribeiro" deve aparecer na lista de unidades cadastradas

  Cenário: Estudante tenta acessar a gestão de restaurantes
    Dado que eu estou logado como um estudante
    Quando eu tento acessar a página de gestão de restaurantes
    Então eu devo ser redirecionado para a página "/home"
    E eu devo ver a mensagem "Acesso restrito a administradores"
