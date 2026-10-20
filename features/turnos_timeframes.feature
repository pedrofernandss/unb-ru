 Feature: Gestão de Turnos e Time-Frames
  Como administrador
  Eu quero definir os horários dos turnos e dividi-los em time-frames configuráveis
  Para organizar a distribuição do FastPass

  Background:
    Given que eu estou logado como um administrador
    And existem os seguintes turnos cadastrados:
      | turno         | inicio | fim   |
      | Café da Manhã | 07:00  | 09:00 |
      | Almoço        | 11:15  | 14:15 |
      | Jantar        | 17:30  | 19:30 |

  Scenario: Editar o horário de um turno
    Given que eu acesso a página de turnos e time-frames
    When eu clico no botão "Editar Horários do Almoço"
    And eu preencho o campo "Início" com "11:00"
    And eu preencho o campo "Fim" com "14:00"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "Turno atualizado com sucesso"
    And o turno "Almoço" deve exibir o horário "11:00 - 14:00"

  Scenario Outline: Editar turno com horário inválido
    Given que eu acesso a página de turnos e time-frames
    When eu clico no botão "Editar Horários do Almoço"
    And eu preencho o campo "Início" com "<inicio>"
    And eu preencho o campo "Fim" com "<fim>"
    And eu clico no botão "Salvar"
    Then eu devo ver a mensagem "<mensagem>"
    And o turno "Almoço" deve exibir o horário "11:15 - 14:15"

    Examples:
      | inicio | fim   | mensagem                                        |
      | 14:00  | 11:00 | O horário final deve ser posterior ao inicial   |
      | 25:00  | 14:15 | Horário inválido                                |
      | 11:15  | 18:00 | O horário do Almoço se sobrepõe ao turno Jantar |

  Scenario: Dividir um turno em time-frames de FastPass
    Given que eu acesso a página de turnos e time-frames
    When eu seleciono "Almoço" no campo "Turno de Referência"
    And eu preencho o campo "Granularidade da Janela" com "15"
    And eu preencho o campo "Tolerância de Atraso" com "3"
    And eu clico no botão "Salvar Configuração"
    Then eu devo ver a mensagem "Time-frames gerados com sucesso"
    And o turno "Almoço" deve possuir 12 time-frames
    And o primeiro time-frame do turno "Almoço" deve ser "11:15 - 11:30"
    And o último time-frame do turno "Almoço" deve ser "14:00 - 14:15"

  Scenario Outline: Configurar time-frames com granularidade inválida
    Given que eu acesso a página de turnos e time-frames
    When eu seleciono "Almoço" no campo "Turno de Referência"
    And eu preencho o campo "Granularidade da Janela" com "<granularidade>"
    And eu preencho o campo "Tolerância de Atraso" com "3"
    And eu clico no botão "Salvar Configuração"
    Then eu devo ver a mensagem "<mensagem>"
    And o turno "Almoço" deve possuir 0 time-frames

    Examples:
      | granularidade | mensagem                                                   |
      | 0             | A granularidade deve ser maior que 0                       |
      | 7             | A granularidade deve dividir a duração do turno (180 min) |
      | quinze        | A granularidade deve ser um número                         |

  Scenario: Estudante tenta acessar a gestão de turnos
    Given que eu estou logado como um estudante
    When eu tento acessar a página de turnos e time-frames
    Then eu devo ser redirecionado para a página "/home"
    And eu devo ver a mensagem "Acesso restrito a administradores"
