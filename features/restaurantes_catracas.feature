Feature: Gestão de Restaurantes e Catracas
  Como administrador
  Eu quero cadastrar, editar e remover restaurantes e suas catracas físicas
  Para que os funcionários possam selecioná-las na Aplicação de Controle

  Background:
    Given que eu estou logado como um administrador
    And existe o restaurante "RU Darcy Ribeiro" com 3 pisos e as seguintes catracas:
      | nome       | piso |
      | Catraca 01 | 1    |
      | Catraca 02 | 1    |

  Scenario: Cadastrar um novo restaurante
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Cadastrar Restaurante"
    And eu preencho o campo "Nome da Unidade" com "RU Gama"
    And eu preencho o campo "Número de Pisos" com "1"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Restaurante cadastrado com sucesso"
    And o restaurante "RU Gama" deve aparecer na lista de unidades cadastradas

  Scenario: Cadastrar restaurante sem nome
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Cadastrar Restaurante"
    And eu deixo o campo "Nome da Unidade" vazio
    And eu preencho o campo "Número de Pisos" com "1"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Nome da Unidade não pode ficar em branco"

  Scenario Outline: Cadastrar restaurante com número de pisos inválido
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Cadastrar Restaurante"
    And eu preencho o campo "Nome da Unidade" com "RU Gama"
    And eu preencho o campo "Número de Pisos" com "<pisos>"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "<mensagem>"

    Examples:
      | pisos | mensagem                                     |
      |       | Número de Pisos não pode ficar em branco     |
      | 0     | Número de Pisos deve ser maior que 0         |
      | três  | Número de Pisos deve ser um número           |

  Scenario: Cadastrar restaurante com nome já existente
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Cadastrar Restaurante"
    And eu preencho o campo "Nome da Unidade" com "RU Darcy Ribeiro"
    And eu preencho o campo "Número de Pisos" com "2"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Já existe um restaurante com esse nome"

  Scenario: Editar o nome de um restaurante
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Editar Unidade" do restaurante "RU Darcy Ribeiro"
    And eu preencho o campo "Nome da Unidade" com "RU Darcy Ribeiro - Central"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Restaurante atualizado com sucesso"
    And o restaurante "RU Darcy Ribeiro - Central" deve aparecer na lista de unidades cadastradas

  Scenario: Associar uma nova catraca a um restaurante
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Associar Nova Catraca"
    And eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    And eu preencho o campo "Nome da Catraca" com "Catraca 04"
    And eu preencho o campo "Piso" com "2"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Catraca associada com sucesso"
    And a catraca "Catraca 04" deve aparecer no piso 2 do restaurante "RU Darcy Ribeiro"

  Scenario Outline: Associar catraca com piso inválido
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Associar Nova Catraca"
    And eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    And eu preencho o campo "Nome da Catraca" com "Catraca 04"
    And eu preencho o campo "Piso" com "<piso>"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "<mensagem>"

    Examples:
      | piso | mensagem                                  |
      | 0    | Piso deve estar entre 1 e 3               |
      | 4    | Piso deve estar entre 1 e 3               |
      | dois | Piso deve ser um número                   |

  Scenario: Associar catraca com nome repetido no mesmo restaurante
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Associar Nova Catraca"
    And eu seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    And eu preencho o campo "Nome da Catraca" com "Catraca 01"
    And eu preencho o campo "Piso" com "1"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Já existe uma catraca com esse nome neste restaurante"

  Scenario: Remover uma catraca
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Remover" da catraca "Catraca 02"
    Then eu devo ver a mensagem "Catraca removida com sucesso"
    And a catraca "Catraca 02" não deve aparecer no restaurante "RU Darcy Ribeiro"

  Scenario: Remover restaurante que ainda possui catracas
    Given que eu acesso a página de gestão de restaurantes
    When eu clico no botão "Remover Unidade" do restaurante "RU Darcy Ribeiro"
    Then eu devo ver a mensagem "Remova as catracas antes de excluir o restaurante"
    And o restaurante "RU Darcy Ribeiro" deve aparecer na lista de unidades cadastradas

  Scenario: Estudante tenta acessar a gestão de restaurantes
    Given que eu estou logado como um estudante
    When eu tento acessar a página de gestão de restaurantes
    Then eu devo ser redirecionado para a página "/home"
    And eu devo ver a mensagem "Acesso restrito a administradores"
